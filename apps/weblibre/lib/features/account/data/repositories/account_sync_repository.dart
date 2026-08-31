/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre and is licensed under the GNU Affero General Public License v3.
 */

import 'package:riverpod/riverpod.dart';

/// Kinds retained only so legacy UI can compile without a remote backend.
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

  const SyncDocumentMetadata({
    required this.id,
    this.label,
    required this.createdAt,
    required this.updatedAt,
    required this.schemaVersion,
    this.sourceDeviceId,
    this.sourceAppVersion,
  });

  factory SyncDocumentMetadata.fromRow(Map<String, dynamic> row) =>
      SyncDocumentMetadata(
        id: row['id'] as String,
        label: row['label'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        schemaVersion: row['schema_version'] as int,
        sourceDeviceId: row['source_device_id'] as String?,
        sourceAppVersion: row['source_app_version'] as String?,
      );
}

class SyncDocumentResult {
  final String contentBlob;
  final SyncDocumentMetadata metadata;
  const SyncDocumentResult({required this.contentBlob, required this.metadata});
}

/// No-op local boundary. It never connects to a server and never transmits data.
class AccountSyncRepository {
  Future<String> storeDocument({
    required SyncDocumentKind kind,
    required int schemaVersion,
    required String contentBlob,
    String? label,
    String? sourceDeviceId,
    String? sourceAppVersion,
  }) async => throw StateError('Remote account sync is disabled in this build.');

  Future<List<SyncDocumentMetadata>> listDocuments({
    required SyncDocumentKind kind,
  }) async => const [];

  Future<SyncDocumentResult?> fetchDocument({required String id}) async => null;

  Future<void> deleteDocument({required String id}) async {
    throw StateError('Remote account sync is disabled in this build.');
  }

  Future<void> updateLabel({required String id, required String? label}) async {
    throw StateError('Remote account sync is disabled in this build.');
  }
}

final accountSyncRepositoryProvider = Provider<AccountSyncRepository>(
  (ref) => AccountSyncRepository(),
);
