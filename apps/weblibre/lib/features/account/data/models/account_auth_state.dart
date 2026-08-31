/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */

/// Local account state retained only as a compatibility boundary.
///
/// The personal WebLibre build has no remote account/authentication service.
enum AccountAuthStatus { signedOut, signingIn, signedIn, error }

class AccountAuthState {
  final AccountAuthStatus status;
  final String? email;
  final String? displayName;
  final String? userId;
  final String? lastError;
  final String? syncKey;
  final Object? client;

  const AccountAuthState({
    this.status = AccountAuthStatus.signedOut,
    this.email,
    this.displayName,
    this.userId,
    this.lastError,
    this.syncKey,
    this.client,
  });

  bool get isSignedIn => status == AccountAuthStatus.signedIn;
  bool get isSignedOut => status == AccountAuthStatus.signedOut;
  bool get isSigningIn => status == AccountAuthStatus.signingIn;
  bool get hasError => status == AccountAuthStatus.error;
  bool get hasSyncKey => syncKey != null;

  AccountAuthState copyWith({
    AccountAuthStatus? status,
    String? email,
    String? displayName,
    String? userId,
    String? lastError,
    String? syncKey,
    Object? client,
  }) => AccountAuthState(
    status: status ?? this.status,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    userId: userId ?? this.userId,
    lastError: lastError ?? this.lastError,
    syncKey: syncKey ?? this.syncKey,
    client: client ?? this.client,
  );
}
