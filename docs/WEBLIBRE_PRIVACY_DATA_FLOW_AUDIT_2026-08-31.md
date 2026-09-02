# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `c5991c6e0d2444c37b195fccdbc23c5d0349af7b`

## Current verification boundary
Privacy/account hardening changes are SOURCE-VERIFIED. Historical Flutter CICD `33420348298` / job `99580917046` proves only its exact older checkpoint; it does not prove the current HEAD. Current-head Actions queries have returned zero runs for the latest cleanup checkpoints, so CI remains NOT VERIFIED.

## Confirmed product rule
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed navigation, search, feeds, proxy/Tor, sign-in, sharing and similar requested browser traffic are not automatically telemetry.

## Confirmed source changes
- User-facing About identity no longer promotes the former upstream developer; required upstream legal notices remain.
- Account callback/handoff startup activation, parser/provider, stream, Android callback deep link, legacy handoff client and generated provider were removed.
- `account_auth.dart` remains a local compatibility boundary with no remote account network I/O.
- The active Firefox Sync implementation is separate: `features/sync` delegates to native Mozilla Android Components account/sync services and remains live.
- Direct application Supabase dependency is removed; legacy handoff transport is gone.
- Search credits/subscription remote RPC paths and search token issuance remain disabled behind local boundaries.
- Account Settings remains a local compatibility route that explicitly states remote personal-build account features are unavailable.
- Automatic `background_fetch` article refresh, dedicated headless entrypoint, and direct application dependency were removed; manual foreground feed refresh remains.
- `apps/weblibre/pubspec.lock` is not present/tracked on the active branch.
- Android `QUERY_ALL_PACKAGES` permission was removed; the narrower intent-query declaration remains for browser/open-with resolution.

## Legacy snapshot-sync cleanup — completed
The current account compatibility screen imports `account_auth` and `AccountAuthStatusCard` and contains no import of the snapshot-sync UI.

Removed as unreachable/retired:
- Snapshot-sync UI widgets
- `AccountSyncRepository` source
- `SyncDocumentService`, `PrefsSyncService`, `SettingsSyncService`
- generated providers for the two sync services
- `SettingsSyncEnvelope` model and generated serialization file
- orphaned `account_sync_repository.g.dart` generated provider artifact discovered after the initial cleanup

The active Firefox Sync feature was not removed or redirected; it remains under `features/sync` with native Mozilla Android Components services.

## Android permission / transport checkpoint
- `QUERY_ALL_PACKAGES` is removed.
- `INTERNET` and `ACCESS_NETWORK_STATE` remain required browser/network capabilities.
- Camera, microphone, location, media/storage, notification and foreground-service declarations remain pending concrete feature-by-feature minimization rather than speculative removal.
- `android:usesCleartextTraffic="true"` remains unchanged pending stronger evidence about all app-level HTTP consumers versus user-directed browser HTTP traffic.
- Custom Tabs, downloads, private-tab notifications, and media session services remain declared and are not treated as dead without reachability proof.

## Outbound endpoint/background audit — current checkpoint
### Firefox Sync
`GeckoSyncApiImpl` uses Mozilla Android Components `FxaAccountManager`/`accountsAuthFeature` for authentication, `syncNow(SyncReason.User)` for explicit sync, and `deviceConstellation` for device discovery, send-tab, and command polling. Synced tabs are read from native remote-tabs storage. `FxaServer` selects the Android Components release server by default, with explicit server/token overrides. There is no parallel WebLibre hard-coded Firefox Sync HTTP transport to remove.

### UnifiedPush
`UnifiedPushReceiver` accepts distributor broadcasts, requires decrypted messages, persists them to the profile-scoped push store and schedules `PushMessageWorker`. The worker restores the owning profile's components and calls the WebLibre Push integration to deliver the message into Gecko. This is an intentional user-enabled background web-push delivery path and must remain.

### Native fetch bridge
`GeckoFetchApiImpl` exposes a Pigeon fetch API backed by `components.core.client`. It constructs Android Components `Request` objects and forwards URL/method/headers/body/redirect/cookie/cache/OHTTP/referrer options to the native client. This is an active browser/network bridge, not a dead compatibility shell. Therefore `INTERNET` remains justified; global `usesCleartextTraffic` still requires broader transport evidence before changing it.

### Legacy Supabase configuration
`apps/weblibre/lib/features/account/data/supabase_config.dart` still exists. A known active consumer is the subscription UI's external account portal URL. The file also contains legacy Supabase URL/anon-key constants. Because branch-scoped repository-wide consumer proof is incomplete, the file is not deleted or renamed in this checkpoint.

## Permission minimization finding
`ACCESS_WIFI_STATE` has a source comment saying it is a Fenix debug-manifest capability, and GitHub's code-search endpoint returned zero concrete `WifiManager` hits, but that search response reported `incomplete_results=true`. No deletion is therefore justified solely from that incomplete index.

## Still pending
1. Finish branch-scoped consumer proof for the remaining `supabase_config.dart` constants and any other app-level HTTP client usages.
2. Complete direct consumer mapping for remaining Android permissions.
3. Decide whether `usesCleartextTraffic` can be removed/narrowed without breaking browser or user-directed flows.
4. Add a local privacy/data-flow screen.
5. Measure APK/runtime cost before unrelated performance removals.
6. Re-run consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection, even with a successful historical build, does not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
