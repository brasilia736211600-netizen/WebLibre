/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_client/search_client.dart';
import 'package:weblibre/features/search_credits/domain/providers.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_credits_repository.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_token_stash_repository.dart';

part 'search_token_issuance_controller.g.dart';

sealed class SearchTokenIssuanceState {
  const SearchTokenIssuanceState();
}

class SearchTokenIssuanceIdle extends SearchTokenIssuanceState {
  const SearchTokenIssuanceIdle();
}

class SearchTokenIssuanceRequesting extends SearchTokenIssuanceState {
  final int count;
  final String idempotencyKey;
  const SearchTokenIssuanceRequesting({
    required this.count,
    required this.idempotencyKey,
  });
}

class SearchTokenIssuanceNeedsPurchase extends SearchTokenIssuanceState {
  final int remainingCredits;
  const SearchTokenIssuanceNeedsPurchase({required this.remainingCredits});
}

class SearchTokenIssuanceNeedsReauth extends SearchTokenIssuanceState {
  const SearchTokenIssuanceNeedsReauth();
}

class SearchTokenIssuanceFailed extends SearchTokenIssuanceState {
  final Object error;
  final StackTrace stackTrace;
  const SearchTokenIssuanceFailed(this.error, this.stackTrace);
}

/// Local-only compatibility boundary. Remote token issuance is disabled.
@Riverpod(keepAlive: true)
class SearchTokenIssuanceController extends _$SearchTokenIssuanceController {
  @override
  SearchTokenIssuanceState build() => const SearchTokenIssuanceIdle();

  Future<IssuanceResult?> issue({required int count}) async {
    state = const SearchTokenIssuanceNeedsReauth();
    return null;
  }

  void reset() {
    state = const SearchTokenIssuanceIdle();
  }
}

enum TokenTopUpOutcome {
  issued,
  noCredits,
  issuanceFailed,
}

enum TokenAvailabilityOutcome {
  available,
  noCredits,
  issuanceFailed,
}

class SearchTokenAvailability {
  final Ref ref;

  SearchTokenAvailability(this.ref);

  Future<TokenAvailabilityOutcome> ensureAvailable() async {
    final stash = ref.read(searchTokenStashProvider);
    if (await stash.count() > 0) return TokenAvailabilityOutcome.available;

    final outcome = await topUp();
    switch (outcome) {
      case TokenTopUpOutcome.issued:
        return (await stash.count()) > 0
            ? TokenAvailabilityOutcome.available
            : TokenAvailabilityOutcome.issuanceFailed;
      case TokenTopUpOutcome.noCredits:
        return TokenAvailabilityOutcome.noCredits;
      case TokenTopUpOutcome.issuanceFailed:
        return TokenAvailabilityOutcome.issuanceFailed;
    }
  }

  Future<TokenTopUpOutcome> topUp({int desired = 10}) async {
    final status = await ref.read(searchCreditsRepositoryProvider.future);
    if (status.availableCredits <= 0) return TokenTopUpOutcome.noCredits;

    final requestCount = min(desired, status.availableCredits);
    final result = await ref
        .read(searchTokenIssuanceControllerProvider.notifier)
        .issue(count: requestCount);
    return result != null
        ? TokenTopUpOutcome.issued
        : TokenTopUpOutcome.issuanceFailed;
  }
}

@Riverpod(keepAlive: true)
SearchTokenAvailability searchTokenAvailability(Ref ref) =>
    SearchTokenAvailability(ref);
