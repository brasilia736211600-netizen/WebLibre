/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';

/// Compatibility boundary for legacy account UI.
///
/// Remote authentication, handoff redemption, session persistence and account
/// synchronization are deliberately unavailable in the personal build.
class AccountAuthRepository extends AsyncNotifier<AccountAuthState> {
  @override
  Future<AccountAuthState> build() async => const AccountAuthState();

  Future<void> startSignIn() async {
    state = const AsyncData(
      AccountAuthState(
        status: AccountAuthStatus.error,
        lastError: 'Remote account sign-in is disabled in this build.',
      ),
    );
  }

  Future<void> cancelSignIn() async {
    state = const AsyncData(AccountAuthState());
  }

  Future<void> handleHandoffCode(String code) async {
    state = const AsyncData(
      AccountAuthState(
        status: AccountAuthStatus.error,
        lastError: 'Remote account handoff is disabled in this build.',
      ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncData(AccountAuthState());
  }

  Future<void> setSyncKey(String key) async {
    state = AsyncData(
      (state.value ?? const AccountAuthState()).copyWith(syncKey: key),
    );
  }

  Future<void> clearSyncKey() async {
    state = AsyncData(
      (state.value ?? const AccountAuthState()).copyWith(syncKey: null),
    );
  }
}

final accountAuthRepositoryProvider =
    AsyncNotifierProvider<AccountAuthRepository, AccountAuthState>(
      AccountAuthRepository.new,
    );

/// Retained for legacy callers; it never performs authentication or network IO.
class AccountAuthFlowException implements Exception {
  final String userMessage;
  const AccountAuthFlowException(this.userMessage);

  @override
  String toString() => userMessage;
}

// Keep the existing import surface stable for code that only referenced the
// old browser-service type through this file. No account operation is invoked.
final _accountBrowserServiceTypeAnchor = GeckoBrowserService;
