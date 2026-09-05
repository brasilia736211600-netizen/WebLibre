/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:country_codes/country_codes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show
        GeckoBrowserService,
        GeckoEngineSettingsService,
        GeckoLoggingService,
        LogLevel;
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:nullability/nullability.dart';
import 'package:privacypass_client/privacypass_client.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/error_observer.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/domain/services/app_initialization.dart';
import 'package:weblibre/domain/services/display_mode.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/engine_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/history/domain/services/history_exclusion_replication.dart';
import 'package:weblibre/features/geckoview/features/history/domain/services/visit_container_recorder.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_observer.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_pruner.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_settings_sync.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_logs.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_autostart.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/main_app.dart';

ColorScheme _fixSurfaceContainerColors(
  ColorScheme scheme,
  TonalPalette neutralPalette,
  Brightness brightness,
) {
  if (brightness == Brightness.light) {
    return scheme.copyWith(
      surfaceContainerLowest: Color(neutralPalette.get(100)),
      surfaceContainerLow: Color(neutralPalette.get(96)),
      surfaceContainer: Color(neutralPalette.get(94)),
      surfaceContainerHigh: Color(neutralPalette.get(92)),
      surfaceContainerHighest: Color(neutralPalette.get(90)),
    );
  } else {
    return scheme.copyWith(
      surfaceContainerLowest: Color(neutralPalette.get(4)),
      surfaceContainerLow: Color(neutralPalette.get(10)),
      surfaceContainer: Color(neutralPalette.get(12)),
      surfaceContainerHigh: Color(neutralPalette.get(17)),
      surfaceContainerHighest: Color(neutralPalette.get(22)),
    );
  }
}

/// Rewrites a dark [ColorScheme] to use pure-black ("OLED"/high-contrast)
/// surfaces.
///
/// Only the *base* tones (the scaffold/page background and the lowest
/// containers) become true black for the power saving. The elevated container
/// tones keep meaningful grey steps so cards, sheets and menus stay visibly
/// separated from the black background — Material elevation shadows are
/// invisible on black, so the surface-tint step is the only separation cue and
/// it must stay perceptible. Steps below ~`#12` are imperceptible near black, so
/// the elevated tones climb in larger increments than the default dark scheme.
ColorScheme _applyPureBlackSurfaces(ColorScheme scheme) {
  return scheme.copyWith(
    surface: const Color(0xFF000000),
    surfaceDim: const Color(0xFF000000),
    surfaceContainerLowest: const Color(0xFF000000),
    surfaceContainerLow: const Color(0xFF121212),
    surfaceContainer: const Color(0xFF1B1B1B),
    surfaceContainerHigh: const Color(0xFF242424),
    surfaceContainerHighest: const Color(0xFF2E2E2E),
  );
}

bool _hasBrokenSurfaceContainerColors(ColorScheme scheme) {
  return scheme.surfaceContainerLowest == scheme.surface &&
      scheme.surfaceContainerLow == scheme.surface &&
      scheme.surfaceContainer == scheme.surface &&
      scheme.surfaceContainerHigh == scheme.surface &&
      scheme.surfaceContainerHighest == scheme.surface;
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

const _noAnimationPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
  },
);

class _MainWidget extends HookConsumerWidget {
  const _MainWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sandboxCaptureControllerProvider);
    ref.watch(singboxProxyLogsProvider.select((_) => null));
    ref.watch(displayModeApplierProvider);

    final rootKey = ref.watch(appStateKeyProvider);

    final pauseTime = useRef<DateTime?>(null);
    useOnAppLifecycleStateChange((previous, current) async {
      switch (current) {
        case AppLifecycleState.resumed:
          if (pauseTime.value != null &&
              DateTime.now().difference(pauseTime.value!) >
                  const Duration(minutes: 30)) {
            final routerConfig = ref
                .read(routerProvider)
                .value
                ?.routerDelegate
                .currentConfiguration;

            ref.read(appStateKeyProvider.notifier).reset();

            await Future.delayed(
              const Duration(milliseconds: 250),
            ).whenComplete(() {
              routerConfig.mapNotNull(
                (routerConfig) =>
                    ref.read(routerProvider).value?.restore(routerConfig),
              );
            });

            logger.i('UI reset');
          }
          pauseTime.value = null;
        case AppLifecycleState.detached:
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
          pauseTime.value ??= DateTime.now();
      }
    });

    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((value) => value.themeMode),
    );
    final uiScaleFactor = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.uiScaleFactor,
      ),
    );
    final disableAnimations = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.disableAnimations,
      ),
    );
    final showModalBarrier = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showModalBarrier,
      ),
    );
    final pureBlack = ref.watch(
      generalSettingsWithDefaultsProvider.select((value) => value.pureBlack),
    );

    useOnInitialization(() async {
      await CountryCodes.init();

      final engineSettings = await ref
          .read(engineSettingsRepositoryProvider.notifier)
          .fetchSettings();
      final generalSettings = await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .fetchSettings();
      final startupUBlockFilterListsPref =
          engineSettings.ublockFilterListSettings.enabled
          ? jsonEncode(
              engineSettings.ublockFilterListSettings.resolveFinalList(),
            )
          : null;
      final clearStartupUBlockFilterListsPref =
          !engineSettings.ublockFilterListSettings.enabled;

      try {
        final snapshot = await readHistoryExclusionSnapshot(
          ref.read(tabDatabaseProvider),
        );

        await GeckoEngineSettingsService().setHistoryExclusions(
          excludedTabIds: snapshot.excludedTabIds,
          knownTabIds: snapshot.knownTabIds,
          excludedContextIds: snapshot.excludedContextIds,
        );
      } catch (e, s) {
        logger.w(
          'Failed initial history-exclusion push at startup',
          error: e,
          stackTrace: s,
        );
      }

      ref.listenManual(
        fireImmediately: true,
        historyExclusionReplicationProvider,
        (previous, next) {},
        onError: (error, stackTrace) {
          logger.e(
            'Error listening to historyExclusionReplicationProvider',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );

      ref.read(visitContainerRecorderProvider);
      ref.read(proxySettingsReplicationProvider);

      try {
        await GeckoBrowserService().initialize(
          filesystem.relativeProfilePath,
          kDebugMode ? LogLevel.debug : LogLevel.warn,
          engineSettings.contentBlocking,
          engineSettings.addonCollection,
          generalSettings.syncServerOverride,
          generalSettings.syncTokenServerOverride,
          engineSettings,
          startupUBlockFilterListsPref,
          clearStartupUBlockFilterListsPref,
        );
      } on PlatformException catch (e, s) {
        logger.e(
          'Platform exception during Gecko initialization',
          error: e,
          stackTrace: s,
        );
        rethrow;
      } catch (e, s) {
        logger.e(
          'Failed to initialize Gecko browser service',
          error: e,
          stackTrace: s,
        );
        rethrow;
      }

      try {
        await syncUBlockFilterLists(
          ref.read(preferenceFixatorProvider.notifier),
          engineSettings,
        );
      } catch (e, s) {
        logger.w(
          'Failed to sync uBlock filter list pref at startup',
          error: e,
          stackTrace: s,
        );
      }

      await ref.read(appInitializationServiceProvider.notifier).initialize();

      Future<void> preloadUrlCleanerCatalog() async {
        if (!generalSettings.urlCleanerEnabled) {
          return;
        }

        try {
          await ref.read(urlCleanerCatalogServiceProvider.future);
        } catch (e, s) {
          logger.w(
            'Failed preloading URL cleaner catalog',
            error: e,
            stackTrace: s,
          );
        }
      }

      unawaited(preloadUrlCleanerCatalog());

      ref.read(localIndexSettingsSyncProvider);
      unawaited(ref.read(localIndexPrunerProvider.notifier).prune());

      unawaited(ref.read(proxyAutostartServiceProvider.notifier).run());
    });

    final corePaletteSnapshot = useFuture(
      useMemoized(() => DynamicColorPlugin.getCorePalette()),
    );

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          final corePalette = corePaletteSnapshot.data;

          final harmonizedLight = lightDynamic.harmonized();
          final harmonizedDark = darkDynamic.harmonized();

          if (corePalette != null) {
            lightColorScheme = _hasBrokenSurfaceContainerColors(harmonizedLight)
                ? _fixSurfaceContainerColors(
                    harmonizedLight,
                    corePalette.neutral,
                    Brightness.light,
                  )
                : harmonizedLight;
            darkColorScheme = _hasBrokenSurfaceContainerColors(harmonizedDark)
                ? _fixSurfaceContainerColors(
                    harmonizedDark,
                    corePalette.neutral,
                    Brightness.dark,
                  )
                : harmonizedDark;
          } else {
            lightColorScheme = harmonizedLight;
            darkColorScheme = harmonizedDark;
          }
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: ref.read(lightSeedColorFallbackProvider),
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: ref.read(darkSeedColorFallbackProvider),
            brightness: Brightness.dark,
          );
        }

        if (pureBlack) {
          darkColorScheme = _applyPureBlackSurfaces(darkColorScheme);
        }

        return MainApp(
          key: rootKey,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            pageTransitionsTheme: disableAnimations
                ? _noAnimationPageTransitionsTheme
                : null,
            dialogTheme: DialogThemeData(
              barrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            bottomSheetTheme: BottomSheetThemeData(
              modalBarrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            extensions: const <ThemeExtension<dynamic>>[AppColors.light],
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            pageTransitionsTheme: disableAnimations
                ? _noAnimationPageTransitionsTheme
                : null,
            dialogTheme: DialogThemeData(
              barrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            bottomSheetTheme: BottomSheetThemeData(
              modalBarrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            extensions: <ThemeExtension<dynamic>>[
              if (pureBlack) AppColors.darkOled else AppColors.dark,
            ],
          ),
          themeMode: themeMode,
          uiScaleFactor: uiScaleFactor,
          disableAnimations: disableAnimations,
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (e) {
    logger.e(e.toString(), error: e.exception, stackTrace: e.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Unhandled Error', error: error, stackTrace: stack);
    return true;
  };

  await filesystem.init();

  await RustLib.init();

  if (kDebugMode) {
    final serviceProtocolInfo = await Service.getInfo();
    logger.d('VM: ${serviceProtocolInfo.serverUri}');
  }

  await Future.delayed(Duration.zero);

  GeckoLoggingService.setUp((level, message) {
    logger.log(switch (level) {
      LogLevel.debug => Level.debug,
      LogLevel.info => Level.info,
      LogLevel.warn => Level.warning,
      LogLevel.error => Level.error,
    }, message);
  });

  await HomeWidget.setAppGroupId('weblibre');

  runApp(
    const ProviderScope(observers: [ErrorObserver()], child: _MainWidget()),
  );
}
