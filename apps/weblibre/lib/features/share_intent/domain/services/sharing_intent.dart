/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */
import 'dart:async';

import 'package:mime/mime.dart' as mime;
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/account/domain/services/account_callback_handler.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/services/intent_gatekeeper.dart';
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'sharing_intent.g.dart';

const _alwaysAllowPackageExtra = 'eu.weblibre.gatekeeper.always_allow_package';

StreamTransformer<Intent, ReceivedIntentParameter>
_buildSharingIntentTransformer(
  IntentGatekeeper gatekeeper,
  GeneralSettingsRepository settingsRepository,
) => StreamTransformer<Intent, ReceivedIntentParameter>.fromHandlers(
  handleData: (intent, sink) async {
    if (_extractAccountCallback(intent) != null) return;

    final alwaysAllowPackage =
        intent.extra[_alwaysAllowPackageExtra] as String?;
    if (alwaysAllowPackage != null) {
      await settingsRepository.updateSettings(
        (current) => current.copyWith.externalAppIntentPolicies({
          ...current.externalAppIntentPolicies,
          alwaysAllowPackage: IntentSourcePolicy.allow,
        }),
      );
    }

    final shortcutContextId = intent.action == 'android.intent.action.VIEW'
        ? intent.extra['pwa_context_id'] as String?
        : null;
    final shortcutContainerMode =
        intent.extra['shortcut_container_mode'] as String?;
    final hasShortcutContainerMetadata =
        shortcutContextId != null || shortcutContainerMode != null;
    final containerMode = intent.action == 'android.intent.action.VIEW'
        ? hasShortcutContainerMetadata
              ? IntentContainerMode.fromWireValue(
                  shortcutContainerMode,
                  contextId: shortcutContextId,
                )
              : IntentContainerMode.unassigned
        : IntentContainerMode.useSelected;

    final allowed = await gatekeeper.shouldAllow(
      fromPackageName: intent.fromPackageName,
      url: intent.data,
    );
    if (!allowed) {
      logger.i(
        'Blocked intent from ${intent.fromPackageName ?? 'unknown app'}',
      );
      return;
    }

    final data = switch (intent.action) {
      'android.intent.action.PROCESS_TEXT' =>
        intent.extra['android.intent.extra.PROCESS_TEXT'] as String?,
      'android.intent.action.WEB_SEARCH' => intent.extra['query'] as String?,
      'android.intent.action.VIEW' => intent.data,
      'android.intent.action.SEND' =>
        intent.extra['android.intent.extra.STREAM'] as String? ??
            intent.extra['android.intent.extra.TEXT'] as String?,
      _ => null,
    };

    final contextId = shortcutContextId;

    if (data != null) {
      if (uri_to_file.isUriSupported(data)) {
        var path = data;
        if (p.extension(data).whenNotEmpty == null) {
          if (intent.mimeType.whenNotEmpty != null) {
            final ext = mime.extensionFromMime(intent.mimeType!);
            if (ext != null) {
              path = p.setExtension(path, '.$ext');
            } else {
              logger.w(
                'Could not determine file extension for: ${intent.mimeType}',
              );
            }
          } else {
            logger.w('Received intent without extension and mime type $path');
          }
        }

        try {
          final file = await uri_to_file.toFile(path);
          final mimeType = mime.lookupMimeType(file.path);
          switch (mimeType) {
            case 'application/pdf':
              sink.add(
                ReceivedIntentParameter(
                  path,
                  null,
                  contextId: contextId,
                  containerMode: containerMode,
                ),
              );
            default:
              logger.w('Unhandled mime type: $mimeType');
          }
        } catch (e) {
          logger.e('Failed to convert URI to file: $e');
          sink.add(
            ReceivedIntentParameter(
              data,
              null,
              contextId: contextId,
              containerMode: containerMode,
            ),
          );
        }
      } else {
        sink.add(
          ReceivedIntentParameter(
            data,
            null,
            contextId: contextId,
            containerMode: containerMode,
          ),
        );
      }
    }
  },
);

@Riverpod(keepAlive: true)
Raw<IntentReceiver> intentReceiver(Ref ref) {
  final receiver = IntentReceiver.setUp();
  ref.onDispose(receiver.dispose);
  return receiver;
}

Raw<Stream<T>> _consumeIntents<T>(
  Ref ref,
  IntentReceiver receiver,
  StreamTransformer<Intent, T> transformer,
) {
  final controller = StreamController<T>();
  final sub = receiver.events
      .transform(transformer)
      .listen(controller.add, onError: controller.addError);

  ref.onDispose(() {
    unawaited(sub.cancel());
    unawaited(controller.close());
  });

  return controller.stream;
}

@Riverpod(keepAlive: true)
Raw<Stream<ReceivedIntentParameter>> sharingIntentStream(Ref ref) {
  final receiver = ref.watch(intentReceiverProvider);
  final gatekeeper = ref.watch(intentGatekeeperProvider.notifier);
  final settingsRepository = ref.watch(
    generalSettingsRepositoryProvider.notifier,
  );
  return _consumeIntents(
    ref,
    receiver,
    _buildSharingIntentTransformer(gatekeeper, settingsRepository),
  );
}

@Riverpod(keepAlive: true)
Raw<Stream<String>> accountCallbackStream(Ref ref) {
  final receiver = ref.watch(intentReceiverProvider);
  return _consumeIntents(ref, receiver, _accountCallbackTransformer);
}

final _accountCallbackTransformer =
    StreamTransformer<Intent, String>.fromHandlers(
      handleData: (intent, sink) {
        final callback = _extractAccountCallback(intent);
        if (callback != null) sink.add(callback.handoffCode);
      },
    );

AccountCallback? _extractAccountCallback(Intent intent) {
  if (intent.action != 'android.intent.action.VIEW' || intent.data == null) {
    return null;
  }
  return tryParseAccountCallback(Uri.parse(intent.data!));
}
