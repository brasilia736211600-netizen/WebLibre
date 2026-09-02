# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-03 checkpoint update  
**Branch:** `weblibre-ua-mainline-v3`  
**Checkpoint:** background-feed automatic refresh removal

## Current verification boundary
The privacy/account hardening changes remain SOURCE-VERIFIED and were previously build-verified by Flutter CICD `33420348298` / job `99580917046` on the exact checkpoint `eea4b40...`. That older build evidence does not prove the newer HEAD. The current Quality workflow has not yet produced a verified run for the newer HEAD.

## Confirmed product rule
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed navigation, search, feeds, proxy/Tor, sign-in, sharing and similar requested browser traffic are not automatically telemetry.

## Confirmed source changes
- User-facing About identity no longer promotes the former upstream developer; required upstream legal notices remain.
- Account callback/handoff startup is disabled as a no-op compatibility boundary.
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
- Manual foreground feed refresh remains available through the existing feed controller path.

## Still pending
1. Prove the remaining dependency graph/lockfile resolves cleanly after removing `background_fetch`.
2. Prove no hidden account/sync initializer remains.
3. Remove dead account/sync source files only after reachability is proven.
4. Complete outbound endpoint/background-service audit.
5. Review Android permissions, `QUERY_ALL_PACKAGES`, and cleartext traffic against concrete feature use.
6. Add a local privacy/data-flow screen.
7. Measure APK/runtime cost before unrelated performance removals.
8. Re-run the consolidated Android validation later, including UA Scenario 1.

## Evidence rule
Source inspection and a successful older Flutter build do not equal current-head CI or Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
