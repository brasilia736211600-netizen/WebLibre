/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/device_info.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/account/data/account_secure_store.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/data/models/account_persisted_data.dart';
import 'package:weblibre/features/account/data/models/persisted_session.dart';
import 'package:weblibre/features/account/data/supabase_config.dart';
import 'package:weblibre/features/account/domain/services/handoff_redeem_client.dart';
import 'package:weblibre/features/account/domain/utils/pkce.dart';
import 'package:weblibre/features/proxy/domain/services/routed_http_client.dart';

export 'package:weblibre/features/account/domain/services/handoff_redeem_client.dart'
    show AccountAuthFlowException;

part 'account_auth.g.dart';

String _sanitizeAuthError(Object error, String fallback) {
  if (error is AccountAuthFlowException) {
    return error.userMessage;
  }
  if (error is AuthRetryableFetchException) {
    return 'Network error. Please check your connection and try again.';
  }
  if (error is AuthException) {
    return error.message;
  }
  return fallback;
}

@Riverpod(keepAlive: true)
class AccountAuthRepository extends _$AccountAuthRepository {
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _signingInTimeout;
  Timer? _restoreRetryTimer;
  String? _redeemingCode;

  AccountSecureStore get _store => ref.read(accountSecureStoreProvider);
  HandoffRedeemClient get _redeemClient =>
      ref.read(handoffRedeemClientProvider);

  AccountAuthState get _currentOrEmpty => state.value ?? AccountAuthState();

  @override
  Future<AccountAuthState> build() async {
    ref.onDispose(() async {
      _signingInTimeout?.cancel();
      _restoreRetryTimer?.cancel();
      await _authSubscription?.cancel();
      final client = state.value?.client;
      await client?.dispose();
    });

    _restoreRetryTimer?.cancel();
    _restoreRetryTimer = null;

    final data = await _store.read();

    if (data.session == null) {
      return AccountAuthState();
    }

    try {
      final client = _createClient();
      final response = await client.auth.setSession(data.session!.refreshToken);

      if (response.session != null) {
        _listenToAuthState(client);
        final user = response.session!.user;

        await _persistSession(response.session!, data);

        return AccountAuthState(
          status: AccountAuthStatus.signedIn,
          email: user.email,
          displayName:
              user.userMetadata?['display_name'] as String? ??
              user.userMetadata?['full_name'] as String? ??
              user.email,
          userId: user.id,
          syncKey: data.syncKey,
          client: client,
        );
      } else {
        await client.dispose();
        return AccountAuthState();
      }
    } on AuthRetryableFetchException catch (e) {
      return _transientRestoreFailure(data, e);
    } on AuthException {
      await _store.clear();
      return AccountAuthState();
    } catch (e) {
      return _transientRestoreFailure(data, e);
    }
  }

  AccountAuthState _transientRestoreFailure(
    AccountPersistedData data,
    Object error,
  ) {
    _scheduleRestoreRetry();
    return AccountAuthState(
      status: AccountAuthStatus.error,
      email: data.email,
      displayName: data.displayName ?? data.email,
      userId: data.userId,
      syncKey: data.syncKey,
      lastError: _sanitizeAuthError(
        error,
        'Could not restore your account session. Retrying shortly.',
      ),
    );
  }

  void _scheduleRestoreRetry() {
    _restoreRetryTimer?.cancel();
    _restoreRetryTimer = Timer(const Duration(seconds: 30), () {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
  }

  SupabaseClient _createClient() {
    return SupabaseClient(
      SupabaseConfig.supabaseUrl,
      SupabaseConfig.supabaseAnonKey,
      httpClient: ref.read(routedHttpClientProvider),
    );
  }

  void _listenToAuthState(SupabaseClient client) {
    unawaited(_authSubscription?.cancel());
    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut ||
          data.event == AuthChangeEvent.userDeleted) {
        unawaited(_handleSignedOut());
      } else if (data.event == AuthChangeEvent.tokenRefreshed &&
          data.session != null) {
        unawaited(_persistSessionRefresh(data.session!));
      }
    });
  }

  Future<void> _handleSignedOut() async {
    await _store.clear();
    await _authSubscription?.cancel();
    final client = state.value?.client;
    await client?.dispose();
    state = AsyncData(AccountAuthState());
  }

  Future<void> startSignIn() async {
    _signingInTimeout?.cancel();
    _signingInTimeout = null;
    state = AsyncData(
      _currentOrEmpty.copyWith(status: AccountAuthStatus.signingIn),
    );

    try {
      final codes = PkceCodes.generate();

      final data = await _store.read();
      await _store.write(data.copyWith(pendingCodeVerifier: codes.verifier));

      final queryParams = <String, String>{
        'mode': 'handoff',
        'code_challenge': codes.challenge,
      };

      final packageInfoData = ref.read(packageInfoProvider).value;
      if (packageInfoData != null) {
        queryParams['app_version'] =
            '${packageInfoData.version}+${packageInfoData.buildNumber}';
      }

      final baseUri = Uri.parse(SupabaseConfig.accountWebUrl);
      final uri = baseUri.replace(queryParameters: queryParams);

      await GeckoBrowserService().openInCustomTab(url: uri, private: false);

      late final Timer timer;
      timer = Timer(const Duration(minutes: 5), () {
        if (!identical(_signingInTimeout, timer)) return;
        _signingInTimeout = null;
        if (state.value?.status == AccountAuthStatus.signingIn) {
          state = AsyncData(
            AccountAuthState(
              status: AccountAuthStatus.error,
              lastError: 'Sign-in timed out. Please try again.',
            ),
          );
        }
      });
      _signingInTimeout = timer;
    } catch (e, s) {
      logger.e('startSignIn failed', error: e, stackTrace: s);
      state = AsyncData(
        _currentOrEmpty.copyWith(
          status: AccountAuthStatus.error,
          lastError: _sanitizeAuthError(
            e,
            'Could not open the sign-in page. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> cancelSignIn() async {
    _signingInTimeout?.cancel();
    _signingInTimeout = null;

    final data = await _store.read();
    await _store.write(data.copyWith(pendingCodeVerifier: null));

    state = AsyncData(AccountAuthState());
  }

  Future<void> handleHandoffCode(String code) async {
    if (_redeemingCode == code) {
      logger.i('Ignoring duplicate handoff callback for in-flight code');
      return;
    }
    _redeemingCode = code;

    _signingInTimeout?.cancel();
    _signingInTimeout = null;
    state = AsyncData(
      _currentOrEmpty.copyWith(status: AccountAuthStatus.signingIn),
    );

    try {
      final data = await _store.read();
      final codeVerifier = data.pendingCodeVerifier;

      if (codeVerifier == null) {
        throw AccountAuthFlowException(
          'No pending sign-in found. Please start sign-in again.',
        );
      }

      final result = await _redeemClient.redeem(
        handoffCode: code,
        codeVerifier: codeVerifier,
      );

      final refreshToken = result.session['refresh_token'] as String;

      final previousClient = _currentOrEmpty.client;
      final newClient = _createClient();

      try {
        await newClient.auth.setSession(refreshToken);
      } catch (e) {
        await newClient.dispose();
        rethrow;
      }

      await previousClient?.dispose();
      _listenToAuthState(newClient);

      final persistedSession = PersistedSession.fromJson(result.session);
      final user = result.session['user'] as Map<String, dynamic>?;
      await _store.write(
        data.copyWith(
          session: persistedSession,
          userId: user?['id'] as String?,
          email: user?['email'] as String?,
          displayName:
              (user?['user_metadata'] as Map<String, dynamic>?)?['display_name']
                  as String?,
          pendingCodeVerifier: null,
        ),
      );

      state = AsyncData(
        AccountAuthState(
          status: AccountAuthStatus.signedIn,
          email: result.account['email'] as String?,
          displayName: result.account['display_name'] as String?,
          userId: result.account['user_id'] as String?,
          syncKey: _currentOrEmpty.syncKey,
          client: newClient,
        ),
      );
    } catch (e, s) {
      logger.e('handleHandoffCode failed', error: e, stackTrace: s);
      state = AsyncData(
        _currentOrEmpty.copyWith(
          status: AccountAuthStatus.error,
          lastError: _sanitizeAuthError(e, 'Sign-in failed. Please try again.'),
        ),
      );
    } finally {
      if (_redeemingCode == code) {
        _redeemingCode = null;
      }
    }
  }

  Future<void> signOut() async {
    try {
      await state.value?.client?.auth.signOut();
    } catch (_) {}
    await _handleSignedOut();
  }

  Future<void> setSyncKey(String key) async {
    final data = await _store.read();
    await _store.write(data.copyWith(syncKey: key));
    state = AsyncData(_currentOrEmpty.copyWith(syncKey: key));
  }

  Future<void> clearSyncKey() async {
    final data = await _store.read();
    await _store.write(data.copyWith(syncKey: null));
    state = AsyncData(_currentOrEmpty.copyWith(syncKey: null));
  }

  Future<void> _persistSession(
    Session session,
    AccountPersistedData current,
  ) async {
    await _store.write(
      current.copyWith(
        session: PersistedSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken!,
          tokenType: session.tokenType,
          expiresIn: session.expiresIn ?? 3600,
        ),
        userId: session.user.id,
        email: session.user.email,
        displayName:
            session.user.userMetadata?['display_name'] as String? ??
            session.user.userMetadata?['full_name'] as String?,
      ),
    );
  }

  Future<void> _persistSessionRefresh(Session session) async {
    final data = await _store.read();
    await _persistSession(session, data);
  }
}
