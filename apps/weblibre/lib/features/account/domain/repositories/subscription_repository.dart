/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/account/data/models/subscription_status.dart';

part 'subscription_repository.g.dart';

/// Local-only compatibility boundary. No account, billing, or subscription
/// information is requested from a remote service.
@Riverpod(keepAlive: true)
class SubscriptionRepository extends _$SubscriptionRepository {
  @override
  Future<SubscriptionStatus> build() async => SubscriptionStatus.inactive;

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
