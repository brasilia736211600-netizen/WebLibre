# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update
**Branch:** `weblibre-ua-mainline-v3`
**Checkpoint:** legacy account callback/handoff + snapshot-sync cleanup + Android package-visibility minimization

## Current verification boundary
Privacy/account hardening changes are SOURCE-VERIFIED. Historical Flutter CICD `33420348298` / job `99580917046` proves only its exact older checkpoint; it does not prove the current HEAD. The current-head GitHub Actions query returned zero runs for the post-cleanup source commit, so CI remains NOT VERIFIED.

## Confirmed product rule
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed navigation, search, feeds, proxy/Tor, sign-in, sharing and similar requested browser traffic are not automatically telemetry.

## Confirmed source changes
- User-facing About identity no longer promotes the former upstream developer; required upstream legal notices remain.
- Account callback/handoff startup activation, parser/provider, stream, Android callback deep link, legacy handoff client and generated provider were removed.
- `account_auth.dart` remains a local compatibility boundary with no remote account network I/O.
- The active Firefox Sync implementation is separate: `features/sync` uses native `GeckoSyncService` / Firefox Account services and remains live.
- Direct application Supabase dependency is removed; legacy handoff transport is gone.
- Search credits/subscription remote RPC paths and search token issuance remain disabled behind local boundaries.
- Account Settings remains a local compatibility route that explicitly states remote personal-build account features are unavailable.
- Automatic `background_fetch` article refresh, dedicated headless entrypoint, and direct application dependency were removed; manual foreground feed refresh remains.
- `apps/weblibre/pubspec.lock` is not present/tracked on the active branch.
- Android `QUERY_ALL_PACKAGES` permission was removed; the narrower intent-query declaration remains for browser/open-with resolution.

## Legacy snapshot-sync cleanup — completed
The current account compatibility screen imports `account_auth` and `AccountAuthStatusCard` and contains no import of the snapshot-sync UI.

Removed as unreachable/retired:
- `SyncDocumentListSection`, `sync_document_dialogs.dart`, `sync_setup_card.dart`
- `AccountSyncRepository`
- `SyncDocumentService`, `PrefsSyncService`, `SettingsSyncService`
- generated providers for the two sync services
- `SettingsSyncEnvelope` model and generated serialization file

The active Firefox Sync feature was not removed or redirected; it remains under `features/sync` with native `GeckoSyncService`.

## Android permission / transport checkpoint
- `QUERY_ALL_PACKAGES` is removed.
- `INTERNET` and `ACCESS_NETWORK_STATE` remain required browser/network capabilities.
- Camera, microphone, location, media/storage, notification and foreground-service declarations remain pending concrete feature-by-feature minimization rather than speculative removal.
- `android:usesCleartextTraffic="true"` remains pending endpoint/transport audit; no broad change is made without evidence about HTTP app services versus user-directed browser traffic.
- Custom Tabs, downloads, private-tab notifications, and media session services remain declared and are not treated as dead without reachability proof.

## Outbound endpoint checkpoint
Known account configuration still contains HTTPS origins for the retired Supabase/account path and current Firefox Sync server overrides. This is configuration evidence only; each active consumer still needs reachability confirmation before endpoint or cleartext changes.

## Still pending
1. Complete outbound endpoint/background-service audit against concrete active consumers.
2. Finish Android permission and cleartext review from that evidence.
3. Add a local privacy/data-flow screen.
4. Measure APK/runtime cost before unrelated performance removals.
5. Re-run consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection, even with a successful historical build, does not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
