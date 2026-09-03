# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD at previous checkpoint:** `148882836f4abc78099126f97b4acf62d0b96da1`

## Current product position
```text
Browser / Container / UA foundation
    source + focused CI                         DONE / historical CI evidence only
    Android runtime restore UA                  FAIL — Scenario 1; source lifecycle stabilization committed, runtime revalidation pending

AI-1 Browser Tool
    specification / inventory / contracts       DONE / SOURCE-VERIFIED
    registry / executor / focused tests         SOURCE-VERIFIED; exception-path regression added; current Quality CI pending
    Agent Core                                  NOT STARTED / BLOCKED

Privacy / Personal Product Hardening
    Account callback/handoff legacy path        REMOVED / SOURCE-VERIFIED
    Legacy snapshot-sync cluster                REMOVED / SOURCE-VERIFIED after reachability review
    Orphaned legacy generated sync artifacts    REMOVED / SOURCE-VERIFIED
    Active Firefox Sync feature                 RETAINED / source-verified native FxaAccountManager path
    Legacy Supabase handoff client              REMOVED / SOURCE-VERIFIED
    Legacy Supabase URL/anon-key config         REMOVED / SOURCE-VERIFIED
    Account portal URL config                   RETAINED / live UI consumer
    Legacy remote-account auth repository/UI    REMOVED / SOURCE-VERIFIED
    Automatic background feed fetch             REMOVED FROM STARTUP
    Background headless feed entrypoint         REMOVED
    Direct background_fetch dependency          REMOVED FROM APP PUBSPEC
    Tracked pubspec.lock                        NOT PRESENT ON ACTIVE BRANCH
    Manual foreground feed refresh              RETAINED
    QUERY_ALL_PACKAGES permission               REMOVED / SOURCE-VERIFIED
    Camera permission                            RETAINED / DIRECTLY JUSTIFIED BY QR SCANNER
    Microphone/location site permissions         RETAINED / DIRECTLY JUSTIFIED BY native site-permission bridge
    POST_NOTIFICATIONS permission               RETAINED / DIRECTLY JUSTIFIED by native site permissions + Web Push settings
    Download/media-selection paths               ACTIVE / exact legacy storage-permission attribution still pending
    outbound app endpoint audit                 PARTIAL / Firefox Sync, Push, native fetch and Core client consumers mapped
    remaining permission/cleartext audit        PENDING direct branch-scoped proof
    local privacy/data-flow screen             PENDING
```

## Latest completed cleanup
The legacy account compatibility route is informational-only. The retired `AccountAuthRepository`, generated provider, `AccountAuthState`, generated state file, and legacy `AccountAuthStatusCard` were removed after the active account screen was reduced to a local informational route and no remaining known consumer was found. The retained account portal origin remains only for the existing subscription UI.

The QR scanner directly requests `Permission.camera` before opening its camera-backed view, so `CAMERA` is a positively justified Android permission and is not a removal candidate.

Active Firefox Sync remains separate and intact through Mozilla Android Components. UnifiedPush remains an intentional user-enabled background delivery path. Native fetch/download paths remain active browser functionality, so no speculative global `usesCleartextTraffic` removal was made.

## Android permission boundary
`INTERNET` and `ACCESS_NETWORK_STATE` remain justified. Foreground services remain backed by concrete DownloadService, PrivateTabsNotificationService, and MediaSessionService integrations. `CAMERA`, microphone, location, and notification site permissions have positive native request-path evidence. The app's Web Push settings also directly calls `Permission.notification.request()` / `openAppSettings()`, so `POST_NOTIFICATIONS` is confirmed active and no longer a removal candidate.

`ACCESS_WIFI_STATE` remains pending because the available branch-scoped code-search response is explicitly incomplete. Legacy storage/media declarations remain pending finer per-permission attribution. `usesCleartextTraffic` remains unchanged pending a complete app-level HTTP consumer map.

## Runtime blocker
Scenario 1 remains FAIL: restored Container A/tab used Gecko/Firefox 152 instead of the configured Chrome/120 UA after relaunch. The restore middleware is installed before `EngineMiddleware.create`, and the native restore binder performs a profile-scoped `tab.db` lookup keyed by the restored tab's `contextId`; runtime revalidation is still required to determine why the lookup/application did not yield the persisted UA in Scenario 1. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI boundary
AI-1 remains source-verified. Current-head Quality CI is not verified. The executor now also has focused regression coverage for backend exception conversion to `executionException`. The Quality workflow is PR-triggered for app/package changes and contains the AI-1/container tests plus native checks; the Flutter CICD workflow is tag/manual rather than push-triggered. AI-2 must remain blocked until browser runtime foundation and current AI-1 CI are validated.

## Release
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production releases remain blocked on runtime/release validation.

## Evidence rule
Never promote:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

## FIRST NEXT STEP — exactly one
**Finish branch-scoped attribution for `ACCESS_WIFI_STATE` and the remaining legacy storage/media permissions, while completing the app-level HTTP/configuration consumer map; then make only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
