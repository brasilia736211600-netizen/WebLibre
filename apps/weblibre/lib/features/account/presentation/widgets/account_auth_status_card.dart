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
import 'package:flutter/material.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';

/// Local compatibility presentation for the retired remote-account path.
///
/// The personal build does not provide remote account authentication or the
/// legacy encrypted snapshot/sync-key service. Keep the route visible for
/// compatibility, but do not expose controls that cannot perform a real action.
class AccountAuthStatusCard extends StatelessWidget {
  const AccountAuthStatusCard({super.key, required this.authState});

  final AccountAuthState authState;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (authState.status) {
      AccountAuthStatus.error => ListTile(
        leading: Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
        title: const Text('WebLibre Account is unavailable'),
        subtitle: Text(
          authState.lastError ??
              'Remote account features are disabled in this personal build.',
        ),
      ),
      AccountAuthStatus.signedOut ||
      AccountAuthStatus.signingIn ||
      AccountAuthStatus.signedIn => const ListTile(
        leading: Icon(Icons.cloud_off_outlined),
        title: Text('Remote account features disabled'),
        subtitle: Text(
          'Account sign-in, cloud synchronization, and the legacy sync-key '
          'service are unavailable in this personal build. Firefox Sync is '
          'managed separately from the browser Sync settings.',
        ),
      ),
    };
  }
}
