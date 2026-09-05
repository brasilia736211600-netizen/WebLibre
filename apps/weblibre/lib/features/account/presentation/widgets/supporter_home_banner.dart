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
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/account/domain/repositories/subscription_repository.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/utils/open_in_custom_tab.dart';

/// Promotional banner shown above the quote card on the browser home page.
class SupporterHomeBanner extends HookConsumerWidget {
  const SupporterHomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learnMoreRecognizer = useMemoized(
      () => TapGestureRecognizer()
        ..onTap = () => openInPrivateCustomTab(
          context,
          'https://docs.weblibre.eu/weblibre/supporter-subscription.html',
        ),
    );
    useEffect(() => learnMoreRecognizer.dispose, [learnMoreRecognizer]);

    final dismissed = ref.watch(
      persistedBoolProvider(PersistedBoolKey.supporterBannerDismissed),
    );
    final subscriptionAsync = ref.watch(subscriptionRepositoryProvider);

    // Subscription status is now a local compatibility boundary. Keep the
    // banner hidden until the status is known, then show it only when inactive.
    final shouldShow =
        kDebugMode ||
        subscriptionAsync.maybeWhen(
          data: (status) => !status.isActive,
          orElse: () => false,
        );

    if (dismissed || !shouldShow) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void dismiss() {
      ref
          .read(
            persistedBoolProvider(
              PersistedBoolKey.supporterBannerDismissed,
            ).notifier,
          )
          .set(true);
    }

    Future<void> openAccount() {
      return AccountSettingsRoute().push(context);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                AppColors.brandPurple.withValues(alpha: 0.16),
                colorScheme.surfaceContainerHigh,
              ),
              colorScheme.surfaceContainer.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.brandPurple.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    MdiIcons.heartOutline,
                    size: 18,
                    color: AppColors.brandPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Support WebLibre',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _DismissButton(onPressed: dismiss),
              ],
            ),
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Supporter is an optional subscription that funds '
                        "WebLibre's development and provides the features that "
                        'need a hosted service to work. The browser and its '
                        'privacy features need no subscription. ',
                  ),
                  TextSpan(
                    text: 'Learn more',
                    style: const TextStyle(
                      color: AppColors.brandPurple,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: learnMoreRecognizer,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _FeatureBullet(
              label: 'WebLibre Search',
              description:
                  'A private, ad-free search built into the browser. It blends '
                  'results from several independent sources, offers tunable '
                  'search modes, can route over Tor, and lets you preview '
                  'pages safely — while keeping your searches unlinkable to '
                  'your account by design.',
            ),
            const SizedBox(height: 8),
            const _FeatureBullet(
              label: 'Encrypted account sync',
              description:
                  'Store and restore your WebLibre settings and preferences '
                  'across profiles and devices. Everything is encrypted on '
                  'your device before upload, so only you can read it.',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: openAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  foregroundColor: colorScheme.surface,
                ),
                icon: const Icon(MdiIcons.heart, size: 18),
                label: const Text('Become a Supporter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String label;
  final String description;

  const _FeatureBullet({required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 6, color: AppColors.brandPurple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: baseStyle?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: description, style: baseStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DismissButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Dismiss',
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      icon: const Icon(Icons.close_rounded),
    );
  }
}
