/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */
import 'package:flutter/material.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Compatibility screen for the legacy account route.
///
/// The personal build has no remote account, subscription, search-credit, or
/// settings-sync service. Keeping this route as a small local screen avoids
/// breaking deep links while making the unavailable remote features explicit.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCustomScrollScaffold(
      title: 'WebLibre Account',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Remote accounts, cloud synchronization, subscriptions, and search credits are disabled in this personal build. Your browsing data stays local unless you explicitly use a feature that requires network access.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
