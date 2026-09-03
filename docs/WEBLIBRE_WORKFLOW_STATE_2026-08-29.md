# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD at previous checkpoint:** `1ab0a22d9695dd4a74378d520c148c93bd37f05a`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`, exact current head is tracked in PR metadata.
- Current source HEAD was revalidated directly against `weblibre-ua-mainline-v3`.
- AI-1 executor source is compile-structured with an explicit terminal fallback after the dispatch switch; no historical missing-return patch was reintroduced.
- A focused regression test was added for backend exceptions, proving the executor's `executionException` result contract at source level.
- Current-head Actions lookup for the new test commit returned zero workflow runs; therefore current-head CI remains NOT VERIFIED.
- Retired account callback/handoff cleanup is complete.
- Legacy snapshot-sync cluster is removed after reachability review.
- Orphaned generated `account_sync_repository.g.dart` was removed.
- Retired Supabase URL/anon-key constants were removed; only the account portal URL remains in the compatibility config because the subscription UI still links to that portal.
- The legacy account route is informational-only; the obsolete account-auth repository, generated provider, state model/generated file, and auth card were removed.
- Active Firefox Sync remains live through `features/sync` + native Mozilla Android Components; it was not touched by the cleanup.
- Android `QUERY_ALL_PACKAGES` remains removed.
- `CAMERA` is positively justified by the QR scanner's direct runtime permission request and camera-backed view.
- Microphone, location, and site-notification runtime permission paths are positively justified by native `SitePermissionsFeature` + Android activity-result handling.
- `POST_NOTIFICATIONS` is independently and directly justified by Web Push settings using `Permission.notification.request()` plus an app-settings fallback.
- Download/media-selection paths are active through native `DownloadsFeature`, prompt permissions, and Android Photo Picker; exact mapping for every legacy storage/media manifest permission is still pending.

## Browser / Android runtime
Scenario 1 remains **FAIL / runtime revalidation pending**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

A source lifecycle stabilization is committed in the branch. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice: `get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, mappings and focused tests remain SOURCE-VERIFIED. The executor now has an additional focused exception-path regression test. Current-head Quality CI remains pending; AI-2 remains blocked.

## Privacy / personal-product hardening
- Legacy account callback/handoff path removed.
- Legacy snapshot-sync path removed after reachability review.
- Orphaned legacy generated sync provider artifact removed.
- Active Firefox Sync retained.
- Automatic background feed fetch/headless entrypoint/direct dependency removed; manual foreground refresh retained.
- `QUERY_ALL_PACKAGES` removed.
- Supabase credentials and obsolete URL configuration removed from the retained account compatibility config; account portal URL retained because it has a live UI consumer.
- Legacy account-auth repository/state/UI cluster removed; account route remains a local compatibility boundary.
- `CAMERA` retained because the active QR scanner requests it explicitly.
- Microphone/location retained because native `SitePermissionsFeature` requests corresponding platform permissions when a site asks for them.
- `POST_NOTIFICATIONS` retained because both native site-permission handling and the Web Push settings service directly request/read the OS notification permission.

## Outbound endpoint/background audit
- Active Firefox Sync delegates to Mozilla Android Components `FxaAccountManager`, account-auth features, explicit `syncNow(SyncReason.User)`, device constellation, and native remote-tabs storage.
- UnifiedPush is a concrete user-enabled background delivery path and remains retained.
- `GeckoFetchApiImpl` is an active browser/native fetch bridge backed by `components.core.client`.
- `Core.client` is also wired into active icon, add-on, web-app shortcut, copy/share/download browser features.
- `DownloadService` uses the shared Android Components HTTP client.
- `android:usesCleartextTraffic="true"` remains unchanged because user-directed HTTP navigation and app-level HTTP transports have not yet been separated with sufficient evidence.

## Android permission audit boundary
- `INTERNET` and `ACCESS_NETWORK_STATE` remain justified by active browser/network features.
- Foreground-service declarations remain justified by concrete download, private-tab notification, and media-session integrations.
- `CAMERA` is source-verified as required by QR scanning.
- Native browser `RequestMultiplePermissions` launchers handle download, site, and prompt permission flows. `SitePermissionsRules` explicitly allow camera, location, notification, and microphone to reach `ASK_TO_ALLOW`, confirming the site-permission bridge remains active.
- `POST_NOTIFICATIONS` additionally has an explicit app-level `Permission.notification.request()` path in Web Push settings, so it is no longer a pending-minimization permission.
- `ACCESS_WIFI_STATE` remains unchanged because available branch-scoped code-search evidence is incomplete; the manifest comment alone is insufficient for deletion.
- `READ_EXTERNAL_STORAGE`/`WRITE_EXTERNAL_STORAGE` and `READ_MEDIA_VISUAL_USER_SELECTED` remain pending finer attribution to determine which declarations are still required on supported Android versions.

## Release
Validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on runtime/release validation.

## Evidence rule
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED` are separate states.

## FIRST NEXT STEP — exactly one
**Finish branch-scoped attribution for `ACCESS_WIFI_STATE` and the remaining legacy storage/media permissions, while completing the app-level HTTP/configuration consumer map; then make only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
