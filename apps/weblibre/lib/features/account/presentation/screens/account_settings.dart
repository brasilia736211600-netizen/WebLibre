/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/account/presentation/widgets/account_auth_status_card.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Compatibility screen for the legacy account route.
///
/// The personal build has no remote account, subscription, search-credit, or
/// settings-sync service. Keeping this route as a small local screen avoids
/// breaking deep links while making the unavailable remote features explicit.
class AccountSettingsScreen extends HookConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(accountAuthRepositoryProvider);

    return SettingsCustomScrollScaffold(
      title: 'WebLibre Account',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: authAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const _AccountDisabledNotice(),
              data: (authState) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AccountDisabledNotice(),
                  const SizedBox(height: 16),
                  AccountAuthStatusCard(authState: authState),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountDisabledNotice extends StatelessWidget {
  const _AccountDisabledNotice();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Remote accounts, cloud synchronization, subscriptions, and search credits are disabled in this personal build. Your browsing data stays local unless you explicitly use a feature that requires network access.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
}
