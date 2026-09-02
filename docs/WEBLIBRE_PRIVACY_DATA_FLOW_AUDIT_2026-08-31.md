# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `5a756952092e62387a47df8af273c75b6af7cec4`

## Current verification boundary
Privacy/account hardening changes are SOURCE-VERIFIED. Historical Flutter CICD `33420348298` / job `99580917046` proves only its exact older checkpoint; it does not prove the current HEAD. The current-head GitHub Actions query for the latest cleanup commit returned zero workflow runs, so CI remains NOT VERIFIED.

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
- `android:usesCleartextTraffic="true"` remains pending endpoint/transport audit; no broad change is made without evidence about HTTP app services versus user-directed browser traffic.
- Custom Tabs, downloads, private-tab notifications, and media session services remain declared and are not treated as dead without reachability proof.

## Outbound endpoint/background audit — mapped Firefox Sync path
`GeckoSyncApiImpl` uses Mozilla Android Components `FxaAccountManager`/`accountsAuthFeature` for authentication, `syncNow(SyncReason.User)` for explicit sync, and `deviceConstellation` for device discovery, send-tab, and command polling. Synced tabs are read from native remote-tabs storage. `FxaServer` selects the Android Components release server by default, with explicit server/token overrides. This confirms there is no parallel WebLibre hard-coded Firefox Sync HTTP transport to remove.

The separate `SupabaseConfig` file still contains HTTPS build-time defaults for the retired account backend. It is currently treated as **unresolved reachability evidence**, not as proof of a live transport; it must not be deleted until branch-specific consumer analysis establishes that no active code imports it.

## Still pending
1. Complete active-consumer audit for remaining app-level HTTP clients, Push/background paths, and concrete permission use.
2. Finish Android permission and cleartext review from that evidence.
3. Add a local privacy/data-flow screen.
4. Measure APK/runtime cost before unrelated performance removals.
5. Re-run consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection, even with a successful historical build, does not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
