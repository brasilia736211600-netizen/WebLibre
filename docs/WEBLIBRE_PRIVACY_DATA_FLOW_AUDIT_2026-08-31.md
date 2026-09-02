# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update  
**Branch:** `weblibre-ua-mainline-v3`  
**Checkpoint:** disabled account startup cleanup (`cea2e984...`)

## Current verification boundary
The privacy/account hardening changes remain SOURCE-VERIFIED and were previously build-verified by Flutter CICD `33420348298` / job `99580917046` on the exact checkpoint `eea4b40...`. That older build evidence does not prove the newer HEAD. The current Quality workflow has not yet produced a verified run for the newer HEAD.

## Confirmed product rule
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed navigation, search, feeds, proxy/Tor, sign-in, sharing and similar requested browser traffic are not automatically telemetry.

## Confirmed source changes
- User-facing About identity no longer promotes the former upstream developer; required upstream legal notices remain.
- Account callback/handoff startup activation has now been removed from `main.dart`; the retained callback service itself remains a disabled no-op compatibility boundary pending full source reachability proof.
- Direct application Supabase dependency is removed.
- Account/Firefox Sync UI categories are removed from personal Settings.
- Account sign-in no longer sends Android `device_name`.
- Account sync forces `source_device_id: null`.
- Search credits and subscription remote RPC paths are disabled behind local boundaries.
- Search token issuance is disabled.
- Account Settings is reduced to local compatibility behavior.
- Share callback parsing remains type-correct while callback redemption/upload remains disabled.
- Automatic `background_fetch` article refresh has been removed from release startup.
- The dedicated `fetch_entrypoint.dart` headless background task has been removed.
- The direct `background_fetch` application dependency has been removed from `apps/weblibre/pubspec.yaml`.
- `apps/weblibre/pubspec.lock` is not present/tracked on the active branch, so there is no repository lockfile entry to edit; no generated lockfile was hand-edited.
- Manual foreground feed refresh remains available through the existing feed controller path.

## Dependency verification result
The active branch `weblibre-ua-mainline-v3` has no direct `background_fetch` dependency in `apps/weblibre/pubspec.yaml`, and no tracked `apps/weblibre/pubspec.lock`. This closes the repository-level dependency/lockfile inspection task. A future `flutter pub get` or CI/build remains the correct generated-dependency validation, but there is no stale lockfile to patch manually.

## Account reachability checkpoint
- `main.dart` no longer imports or activates `accountCallbackHandlerProvider`.
- `app_initialization.dart` contains no account callback initialization.
- `account_auth.dart` is a local compatibility boundary and does not import or invoke `handoff_redeem_client.dart`.
- `handoff_redeem_client.dart` still contains a real `handoff-redeem` HTTP client and is therefore retained until every active-branch consumer is proven absent.
- `prefs_sync_service.dart`, `settings_sync_service.dart`, and `sync_document_service.dart` currently implement serialization/application boundaries and are retained pending consumer reachability proof.

## Still pending
1. Prove the remaining account/sync source reachability graph and remove only files with hard active-branch no-consumer evidence.
2. Complete outbound endpoint/background-service audit.
3. Review Android permissions, `QUERY_ALL_PACKAGES`, and cleartext traffic against concrete feature use.
4. Add a local privacy/data-flow screen.
5. Measure APK/runtime cost before unrelated performance removals.
6. Re-run the consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection and a successful older Flutter build do not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.