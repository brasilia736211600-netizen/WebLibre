# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-04 checkpoint update
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD at previous checkpoint:** `28a1ebcb4285494cc3f6cb3783c71841cf716941`

## Current verification boundary
Privacy/account hardening changes are SOURCE-VERIFIED. Historical CI runs prove only their exact checkpoints; they do not prove the current HEAD. Current-head Actions queries for the latest branch commits return zero runs, so current-head CI remains NOT VERIFIED.

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
- `CAMERA` is positively justified by the QR scanner's direct runtime request.
- The native browser fragment installs `RequestMultiplePermissions` launchers for downloads, site permissions, and prompt-driven permissions. Its site-permission rules allow camera, microphone, location, and notification requests to reach the Android permission launcher. This keeps those paths active.
- Web Push settings has an explicit OS notification-permission request path and an app-settings fallback, so `POST_NOTIFICATIONS` remains justified.
- Native download/prompt permission handling and Android Photo Picker confirm active download/media-selection flows. The exact mapping of each legacy storage/media manifest permission remains unresolved.
- `ACCESS_WIFI_STATE` remains unchanged because available branch-scoped code-search evidence is explicitly incomplete; the manifest comment alone is not sufficient deletion evidence.
- `android:usesCleartextTraffic="true"` remains unchanged pending a complete separation of user-directed browser HTTP from app-level HTTP transport requirements.
- Custom Tabs, downloads, private-tab notifications, and media session services remain declared because they have concrete active integrations.

## Outbound endpoint/background audit — current checkpoint
### Firefox Sync
`GeckoSyncApiImpl` uses Mozilla Android Components `FxaAccountManager`/`accountsAuthFeature` for authentication, `syncNow(SyncReason.User)` for explicit sync, and `deviceConstellation` for device discovery, send-tab, and command polling. Synced tabs are read from native remote-tabs storage. There is no parallel WebLibre hard-coded Firefox Sync HTTP transport to remove.

### UnifiedPush
`UnifiedPushReceiver` accepts distributor broadcasts, requires decrypted messages, persists them to the profile-scoped push store and schedules `PushMessageWorker`. The worker restores the owning profile's components and delivers the message into Gecko. This is an intentional user-enabled background web-push path and must remain.

### Native fetch/client consumers
`Core.client` is a live Android Components fetch client. It is wired into active browser icons, add-on provider/updater paths, web-app shortcut support, copy/share/download functionality, and the Pigeon `GeckoFetchApiImpl` browser fetch bridge. These are active browser/network consumers, so `INTERNET` remains justified. Global `usesCleartextTraffic` still requires broader transport evidence before changing it.

## AI-1 checkpoint
The model-independent Browser Tool slice remains source-verified. The executor now has focused regression coverage for permission denial, unknown tools, invalid input, successful navigation dispatch, and backend exception conversion to `executionException`. No global provider/LLM dependency was introduced.

## Permission minimization finding
`ACCESS_WIFI_STATE` remains pending branch-scoped proof. Legacy storage/media declarations remain pending finer per-permission attribution. No speculative manifest reduction is made without direct evidence.

## Remaining opportunities
1. Finish branch-scoped consumer proof for `ACCESS_WIFI_STATE`, remaining media/storage permissions, and remaining app-level HTTP/configuration consumers.
2. Decide whether `usesCleartextTraffic` can be removed/narrowed without breaking browser or user-directed flows.
3. Add a local privacy/data-flow screen.
4. Measure APK/runtime cost before unrelated performance removals.
5. Re-run consolidated Android validation later, with UA Scenario 1 first.

## Evidence rule
Source inspection does not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
