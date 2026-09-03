# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `6b81828fb08b170467c2fc053b74973f247c7a32`

## Current verification boundary
Privacy/account hardening changes are SOURCE-VERIFIED. Historical Flutter CICD `33420348298` / job `99580917046` proves only its exact older checkpoint; it does not prove the current HEAD. Current-head Actions queries have returned zero runs for the latest cleanup checkpoints, so CI remains NOT VERIFIED.

## Confirmed product rule
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed navigation, search, feeds, proxy/Tor, sign-in, sharing and similar requested browser traffic are not automatically telemetry.

## Confirmed source changes
- User-facing About identity no longer promotes the former upstream developer; required upstream legal notices remain.
- Account callback/handoff startup activation, parser/provider, stream, Android callback deep link, legacy handoff client and generated provider were removed.
- The retained Account route is informational-only; the retired account-auth repository, generated provider, account-auth state model/generated file, and legacy auth card were removed after the active route no longer referenced them.
- The active Firefox Sync implementation is separate: `features/sync` delegates to native Mozilla Android Components account/sync services and remains live.
- Direct application Supabase dependency is removed; legacy handoff transport is gone.
- Search credits/subscription remote RPC paths and search token issuance remain disabled behind local boundaries.
- Account Settings explicitly states remote personal-build account features are unavailable.
- Automatic `background_fetch` article refresh, dedicated headless entrypoint, and direct application dependency were removed; manual foreground feed refresh remains.
- `apps/weblibre/pubspec.lock` is not present/tracked on the active branch.
- Android `QUERY_ALL_PACKAGES` permission was removed; the narrower intent-query declaration remains for browser/open-with resolution.

## Legacy snapshot-sync cleanup — completed
Removed as unreachable/retired:
- Snapshot-sync UI widgets
- `AccountSyncRepository` source and generated provider artifact
- `SyncDocumentService`, `PrefsSyncService`, `SettingsSyncService`
- generated providers for the two sync services
- `SettingsSyncEnvelope` model and generated serialization file

The active Firefox Sync feature was not removed or redirected; it remains under `features/sync` with native Mozilla Android Components services.

## Legacy account-auth cleanup — completed
The account compatibility route was reduced to an informational screen, making the old account-auth state/repository/UI cluster unreachable from the retained route. The obsolete repository, generated provider, state model/generated file, and auth card were removed. This does not affect browser Firefox Sync.

## Supabase configuration cleanup — completed
`apps/weblibre/lib/features/account/data/supabase_config.dart` retains only the account portal origin used by the existing subscription UI. The retired `SUPABASE_URL` and `SUPABASE_ANON_KEY` build-time constants, including the embedded anon credential, were removed.

## Android permission / transport checkpoint
- `QUERY_ALL_PACKAGES` is removed.
- `INTERNET` and `ACCESS_NETWORK_STATE` remain required browser/network capabilities.
- `CAMERA` is positively justified: the QR scanner explicitly calls `Permission.camera.request()` before opening the camera-backed QR view. fileciteturn168file0
- The native browser fragment installs Android `RequestMultiplePermissions` launchers for downloads, site permissions, and prompt-driven permissions. Its `SitePermissionsRules` configure camera, microphone, location, and notification as `ASK_TO_ALLOW`, with the returned platform permission set passed to the Android activity-result launcher. This is direct source evidence that microphone, location, and site-notification runtime permission paths remain active. fileciteturn253file0L2-L2
- Web Push settings also exposes an explicit OS notification-permission action through `Permission.notification.request()` and `openAppSettings()`. This independently confirms that `POST_NOTIFICATIONS` has an active application-level consumer, not merely a transitive manifest declaration. fileciteturn231file0L2-L2 fileciteturn232file0L2-L2
- The same native browser fragment wires `DownloadsFeature` to the download permission launcher and `PromptFeature` to a separate prompt permission launcher, while Android Photo Picker is used for single/multi media selection. This positively establishes active download/media-selection paths, but the exact mapping of every legacy storage/media manifest permission still requires finer per-permission attribution before removal. fileciteturn253file0L2-L2
- Camera hardware remains optional in the manifest, so devices without camera hardware are not excluded.
- `ACCESS_WIFI_STATE` remains unchanged because the strongest available branch-scoped code-search result is explicitly incomplete; the manifest comment alone is not sufficient deletion evidence. fileciteturn242file0L2-L2
- `android:usesCleartextTraffic="true"` remains unchanged pending stronger evidence about all app-level HTTP consumers versus user-directed browser HTTP traffic.
- Custom Tabs, downloads, private-tab notifications, and media session services remain declared and are not treated as dead without reachability proof.

## Outbound endpoint/background audit — current checkpoint
### Firefox Sync
`GeckoSyncApiImpl` uses Mozilla Android Components `FxaAccountManager`/`accountsAuthFeature` for authentication, `syncNow(SyncReason.User)` for explicit sync, and `deviceConstellation` for device discovery, send-tab, and command polling. Synced tabs are read from native remote-tabs storage. `FxaServer` selects the Android Components release server by default, with explicit server/token overrides. There is no parallel WebLibre hard-coded Firefox Sync HTTP transport to remove.

### UnifiedPush
`UnifiedPushReceiver` accepts distributor broadcasts, requires decrypted messages, persists them to the profile-scoped push store and schedules `PushMessageWorker`. The worker restores the owning profile's components and calls the WebLibre Push integration to deliver the message into Gecko. This is an intentional user-enabled background web-push delivery path and must remain.

### Native fetch/client consumers
`Core.client` is a live Android Components fetch client. The current `Core` wires that client into browser icons, add-on provider/updater paths, web-app shortcut support, and the browser fragment's copy/share/download features; the Pigeon `GeckoFetchApiImpl` also exposes the same native client as an explicit browser fetch bridge. These are active browser/network consumers, so `INTERNET` remains justified. Global `usesCleartextTraffic` still requires broader transport evidence before changing it because user-directed HTTP navigation and app-level HTTP requests have not yet been cleanly separated by policy.

## Permission minimization finding
`ACCESS_WIFI_STATE` has a source comment saying it is a Fenix debug-manifest capability. Available GitHub code-search evidence is incomplete, so no deletion is justified solely from that search result. The current manifest is therefore intentionally unchanged for this permission. fileciteturn242file0L2-L2

## Remaining opportunities
1. Finish branch-scoped consumer proof for `ACCESS_WIFI_STATE`, remaining media/storage permissions, and any remaining app-level HTTP/configuration consumers.
2. Decide whether `usesCleartextTraffic` can be removed/narrowed without breaking browser or user-directed flows.
3. Add a local privacy/data-flow screen.
4. Measure APK/runtime cost before unrelated performance removals.
5. Re-run consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection, even with a successful historical build, does not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
