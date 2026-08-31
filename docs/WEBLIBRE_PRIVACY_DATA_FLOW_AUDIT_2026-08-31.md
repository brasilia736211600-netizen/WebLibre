# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-09-01 checkpoint update  
**Branch:** `weblibre-ua-mainline-v3`  
**Checkpoint:** `eea4b40baef357136d38e057f708106aeb112da0`

## Current verification boundary
The privacy/account hardening changes remain SOURCE-VERIFIED and are now build-verified by Flutter CICD `33420348298` / job `99580917046` on the exact checkpoint `eea4b40...`. This is not Android-runtime proof and does not substitute for the current Quality workflow.

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

## Still pending
1. Remove automatic `background_fetch` article refresh from release startup while retaining manual feed refresh.
2. Prove no hidden account/sync initializer remains.
3. Remove dead account/sync source files only after reachability is proven.
4. Complete outbound endpoint/background-service audit.
5. Review Android permissions, `QUERY_ALL_PACKAGES`, and cleartext traffic against concrete feature use.
6. Add a local privacy/data-flow screen.
7. Measure APK/runtime cost before unrelated performance removals.

## Evidence rule
Source inspection and successful Flutter build do not equal Android runtime verification. Every material privacy change follows:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`.
