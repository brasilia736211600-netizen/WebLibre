# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update  
**Branch:** `weblibre-ua-mainline-v3`  
**Checkpoint:** legacy account callback/handoff cleanup + Android package-visibility minimization

## Current verification boundary
The privacy/account hardening changes remain SOURCE-VERIFIED and were previously build-verified by Flutter CICD `33420348298` / job `99580917046` on the exact checkpoint `eea4b40...`. That older build evidence does not prove the newer HEAD. The current Quality workflow has not yet produced a verified run for the newer HEAD.

## Confirmed product rule
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed navigation, search, feeds, proxy/Tor, sign-in, sharing and similar requested browser traffic are not automatically telemetry.

## Confirmed source changes
- User-facing About identity no longer promotes the former upstream developer; required upstream legal notices remain.
- Account callback/handoff startup activation was removed from `main.dart`.
- The legacy account callback parser/provider and generated bindings were removed after their application consumer was removed.
- The legacy `weblibre://account` Android deep-link intent filter was removed because the corresponding callback path is disabled and no longer exists.
- The legacy Supabase `handoff-redeem` HTTP client and generated provider were removed after the application auth boundary stopped importing/invoking them and the callback stream was removed.
- The active Firefox Sync implementation is separate: `features/sync` uses native `GeckoSyncService` / Firefox Account services and remains a live feature; it is not treated as dead legacy code by this cleanup.
- Direct application Supabase dependency is removed.
- Account sign-in no longer sends Android `device_name` through the removed legacy path.
- Account sync source-device identifier hardening remains documented in the existing privacy baseline.
- Search credits and subscription remote RPC paths are disabled behind local boundaries.
- Search token issuance is disabled.
- Account Settings remains a local compatibility route that states remote personal-build account features are unavailable.
- Automatic `background_fetch` article refresh has been removed from release startup.
- The dedicated `fetch_entrypoint.dart` headless background task has been removed.
- The direct `background_fetch` application dependency has been removed from `apps/weblibre/pubspec.yaml`.
- `apps/weblibre/pubspec.lock` is not present/tracked on the active branch, so there is no repository lockfile entry to edit; no generated lockfile was hand-edited.
- Manual foreground feed refresh remains available through the existing feed controller path.
- Android `QUERY_ALL_PACKAGES` permission was removed from the app manifest. The manifest retains the narrower intent-query declaration needed for browser/open-with resolution; this is SOURCE-VERIFIED and still requires current-head build/runtime confirmation.

## Account reachability checkpoint
- `main.dart` no longer imports or activates the retired account callback provider.
- `sharing_intent.dart` no longer parses account callback intents or exposes `accountCallbackStreamProvider`.
- `account_auth.dart` is a local compatibility boundary and does not import the removed handoff client.
- `handoff_redeem_client.dart` and its generated provider are removed.
- The account test subtree contains no handoff-redeem test consumer.
- The remaining legacy snapshot-sync widget/service cluster is still being audited separately; it must not be removed merely because the remote account path is disabled.

## Android permission / transport checkpoint
- `QUERY_ALL_PACKAGES` is removed from `apps/weblibre/android/app/src/main/AndroidManifest.xml`.
- `INTERNET` and `ACCESS_NETWORK_STATE` remain required browser/network capabilities.
- Camera, microphone, location, media/storage, notification and foreground-service declarations remain pending concrete feature-by-feature minimization rather than speculative removal.
- `android:usesCleartextTraffic="true"` remains pending endpoint/transport audit. It is not changed without proving that HTTP browser behavior and/or a concrete app service does not depend on it.
- Custom Tabs, downloads, private-tab notifications, and media session services remain declared and are not treated as dead without reachability proof.

## Still pending
1. Finish reachability proof for the remaining legacy account snapshot-sync cluster (`prefs_sync_service`, `settings_sync_service`, `sync_document_service`, and their widget/repository callers) and delete only hard-proven dead sources.
2. Complete outbound endpoint/background-service audit.
3. Finish Android permission and cleartext review against concrete feature use.
4. Add a local privacy/data-flow screen.
5. Measure APK/runtime cost before unrelated performance removals.
6. Re-run the consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection and a successful older Flutter build do not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
