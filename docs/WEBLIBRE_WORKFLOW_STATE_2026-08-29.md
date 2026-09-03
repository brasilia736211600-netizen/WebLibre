# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-04
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD at current checkpoint:** `237bf11260e9154297b23ad2f45e5bbdaf7c47ed`

## Source of truth
GitHub code, refs, commits, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`, exact current head is `237bf11260e9154297b23ad2f45e5bbdaf7c47ed`.
- AI-1 executor keeps the explicit terminal fallback after the dispatch switch; no historical missing-return patch was reintroduced.
- Browser-tool audit events are emitted through an optional executor callback for every execution result, including denied, invalid, failed, and successful paths.
- Focused AI-1 regression coverage includes backend exception conversion, audit emission, and the complete six-tool permission/side-effect matrix.
- Current-head Quality Actions/status lookup for `237bf11260e9154297b23ad2f45e5bbdaf7c47ed` returns no run/status; current-head CI remains NOT VERIFIED.
- A new UA restore fix is now source-committed: `ContainerUserAgentCreateSessionMiddleware` intercepts engine-session creation before Android Components' creation middleware, creates the session, applies the persisted container UA, restores the engine session state, reapplies the UA defensively, then dispatches `LinkEngineSessionAction`. `Core` wires this middleware before `EngineMiddleware.create(...)`.
- The fix was chosen from current dependency lifecycle evidence: Android Components creates the session and calls `restoreState()` before dispatching `LinkEngineSessionAction`, so link-time-only UA assignment can be too late for the first restored navigation.
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

A source lifecycle fix intended to close Scenario 1 is committed at `237bf11260e9154297b23ad2f45e5bbdaf7c47ed`, but it is not yet CI- or Android-runtime-verified. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice: `get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, mappings and focused tests remain SOURCE-VERIFIED. The executor emits its `BrowserToolAuditEvent` through an optional callback so the calling layer can persist/route audit records without coupling the executor to a storage/provider implementation. The registry has explicit permission/side-effect matrix coverage. Current-head Quality CI remains pending; AI-2 remains blocked.

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
**Obtain fresh current-head Quality CI for `237bf11260e9154297b23ad2f45e5bbdaf7c47ed`; then, on a green build, run only Android Scenario 1 to verify the restored container UA before proceeding to any other runtime scenario.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`