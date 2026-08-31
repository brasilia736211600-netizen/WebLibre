/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';

part 'account_sync_repository.g.dart';

enum SyncDocumentKind {
  weblibreSettings('weblibre_settings', 'Settings'),
  geckoUserJs('gecko_user_js', 'Gecko Prefs'),
  syncValidationProbe('sync_validation_probe', 'Sync Validation Probe');

  final String value;
  final String displayName;

  const SyncDocumentKind(this.value, this.displayName);
}

class SyncDocumentMetadata {
  final String id;
  final String? label;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sourceDeviceId;
  final String? sourceAppVersion;
  final int schemaVersion;

  SyncDocumentMetadata({
    required this.id,
    this.label,
    required this.createdAt,
    required this.updatedAt,
    required this.schemaVersion,
    this.sourceDeviceId,
    this.sourceAppVersion,
  });

  factory SyncDocumentMetadata.fromRow(Map<String, dynamic> row) {
    return SyncDocumentMetadata(
      id: row['id'] as String,
      label: row['label'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      schemaVersion: row['schema_version'] as int,
      sourceDeviceId: row['source_device_id'] as String?,
      sourceAppVersion: row['source_app_version'] as String?,
    );
  }
}

class SyncDocumentResult {
  final String contentBlob;
  final SyncDocumentMetadata metadata;

  SyncDocumentResult({required this.contentBlob, required this.metadata});
}

/// All write methods on this repository require the user to be signed in.
/// Device identifiers are deliberately discarded at the repository boundary
/// even if a legacy caller supplies one.
@Riverpod(keepAlive: true)
class AccountSyncRepository extends _$AccountSyncRepository {
  @override
  SupabaseClient? build() {
    final authState = ref.watch(accountAuthRepositoryProvider).value;
    if (authState == null || !authState.isSignedIn) return null;
    return authState.client;
  }

  SupabaseClient get _client {
    final client = state;
    if (client == null) {
      throw StateError(
        'AccountSyncRepository called while signed-out. '
        'Gate the call site on accountAuthRepositoryProvider.isSignedIn '
        'or accountSyncRepositoryProvider != null first.',
      );
    }
    return client;
  }

  Future<String> storeDocument({
    required SyncDocumentKind kind,
    required int schemaVersion,
    required String contentBlob,
    String? label,
    String? sourceDeviceId,
    String? sourceAppVersion,
  }) async {
    final row = await _client
        .from('account_sync_documents')
        .insert({
          'user_id': _client.auth.currentUser!.id,
          'document_kind': kind.value,
          'label': label,
          'schema_version': schemaVersion,
          'content_blob': contentBlob,
          'source_device_id': null,
          'source_app_version': sourceAppVersion,
        })
        .select('id')
        .single();

    return row['id'] as String;
  }

  Future<List<SyncDocumentMetadata>> listDocuments({
    required SyncDocumentKind kind,
  }) async {
    final rows = await _client
        .from('account_sync_documents')
        .select(
          'id, label, created_at, updated_at, schema_version, '
          'source_device_id, source_app_version',
        )
        .eq('document_kind', kind.value)
        .order('updated_at', ascending: false);

    return rows.map(SyncDocumentMetadata.fromRow).toList();
  }

  Future<SyncDocumentResult?> fetchDocument({required String id}) async {
    final row = await _client
        .from('account_sync_documents')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;

    return SyncDocumentResult(
      contentBlob: row['content_blob'] as String,
      metadata: SyncDocumentMetadata.fromRow(row),
    );
  }

  Future<void> deleteDocument({required String id}) async {
    await _client.from('account_sync_documents').delete().eq('id', id);
  }

  Future<void> updateLabel({required String id, required String? label}) async {
    await _client
        .from('account_sync_documents')
        .update({'label': label})
        .eq('id', id);
  }
}
