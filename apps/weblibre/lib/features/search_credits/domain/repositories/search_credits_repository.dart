/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/search_credits/data/models/search_credits_status.dart';

part 'search_credits_repository.g.dart';

/// Local-only compatibility boundary. The personal build has no remote
/// account/search-credit service and never transmits account or balance data.
@Riverpod(keepAlive: true)
class SearchCreditsRepository extends _$SearchCreditsRepository {
  @override
  Future<SearchCreditsStatus> build() async => SearchCreditsStatus.empty;

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
