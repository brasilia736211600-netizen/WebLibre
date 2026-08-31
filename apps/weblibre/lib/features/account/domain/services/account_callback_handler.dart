/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_callback_handler.g.dart';

/// Parsed shape retained only so the legacy intent parser remains type-safe.
/// The personal build never redeems or transmits the callback.
class AccountCallback {
  final String handoffCode;
  const AccountCallback(this.handoffCode);
}

AccountCallback? tryParseAccountCallback(Uri uri) {
  if (uri.scheme != 'weblibre' || uri.host != 'account') return null;
  final code = uri.queryParameters['handoff_code'];
  if (code == null || code.isEmpty) return null;
  return AccountCallback(code);
}

/// Account callbacks are intentionally disabled in the personal WebLibre build.
@Riverpod(keepAlive: true)
void accountCallbackHandler(Ref ref) {}
