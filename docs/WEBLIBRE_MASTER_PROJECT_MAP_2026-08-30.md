# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD at current checkpoint:** `3be7de126e6342a2ade388a897c5e51674acb018`

## Current product position
```text
Browser / Container / UA foundation
    source + historical focused CI                 DONE / current-head CI pending
    Android runtime restore UA                     SOURCE FIX COMMITTED / Scenario 1 runtime revalidation pending

AI-1 Browser Tool
    specification / inventory / contracts          DONE / SOURCE-VERIFIED
    registry / executor / focused tests            SOURCE-VERIFIED; exception + permission/audit coverage added
    Agent Core                                     NOT STARTED / BLOCKED

Privacy / Personal Product Hardening
    Account callback/handoff legacy path            REMOVED / SOURCE-VERIFIED
    Legacy snapshot-sync cluster                    REMOVED / SOURCE-VERIFIED after reachability review
    Orphaned legacy generated sync provider         REMOVED / SOURCE-VERIFIED
    Active Firefox Sync feature                     RETAINED / source-verified native FxaAccountManager path
    Legacy Supabase handoff client                  REMOVED / SOURCE-VERIFIED
    Legacy Supabase URL/anon-key config             REMOVED / SOURCE-VERIFIED
    Account portal URL config                       RETAINED / live UI consumer
    Legacy remote-account auth repository/UI        REMOVED / SOURCE-VERIFIED
    Automatic background feed fetch                 REMOVED FROM STARTUP
    Background headless feed entrypoint             REMOVED
    Direct background_fetch dependency              REMOVED FROM APP PUBSPEC
    Tracked pubspec.lock                            NOT PRESENT ON ACTIVE BRANCH
    Manual foreground feed refresh                  RETAINED
    QUERY_ALL_PACKAGES permission                   REMOVED / SOURCE-VERIFIED
    Camera permission                               RETAINED / DIRECTLY JUSTIFIED BY QR SCANNER
    Microphone/location site permissions             RETAINED / DIRECTLY JUSTIFIED BY native site-permission bridge
    POST_NOTIFICATIONS permission                   RETAINED / DIRECTLY JUSTIFIED by native site permissions + Web Push settings
    Download/media-selection paths                  ACTIVE / exact legacy storage-permission attribution pending
    outbound app endpoint audit                     PARTIAL / Firefox Sync, Push, native fetch and Core client consumers mapped
    remaining permission/cleartext audit            PENDING direct branch-scoped proof
    local privacy/data-flow screen                 PENDING
```

## Current checkpoint
The per-container UA lifecycle fix is source-committed. `ContainerUserAgentCreateSessionMiddleware` is wired before Android Components' engine-session creation path; it creates the restored session, applies the persisted container UA before `restoreState()`, reapplies it defensively, and then dispatches `LinkEngineSessionAction`.

The implementation follows the current Android Components creation lifecycle evidence: restored engine state is applied before application link-time middleware runs, so a link-time-only UA assignment can be too late for the first restored navigation.

AI-1 remains a minimal model-independent six-tool Browser Tool slice with source-level regression coverage for unknown tools, permission denial, invalid inputs, backend exceptions, audit emission, and the explicit permission/side-effect matrix.

## Android permission boundary
`INTERNET` and `ACCESS_NETWORK_STATE` remain justified. Foreground-service declarations remain backed by concrete DownloadService, PrivateTabsNotificationService, and MediaSessionService integrations. `CAMERA`, microphone, location, and site-notification permissions have positive native request-path evidence. Web Push settings independently requests Android notification permission.

`ACCESS_WIFI_STATE` remains pending because branch-scoped code-search evidence is insufficient for safe deletion. `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, and `READ_MEDIA_VISUAL_USER_SELECTED` remain pending finer attribution. `usesCleartextTraffic="true"` remains unchanged pending complete separation of user-directed browser navigation from app-level HTTP transports.

## Runtime blocker
Scenario 1 remains **FAIL / runtime revalidation pending** based on the prior Android run:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

The source lifecycle fix intended to close this failure is committed in the current branch, but it is **not CI-verified or Android-runtime-verified** at the current head. Do not run Scenarios 2–6 until Scenario 1 passes.

## CI evidence
Current branch HEAD is `3be7de126e6342a2ade388a897c5e51674acb018`. GitHub Actions lookup for that exact SHA returns zero workflow runs and zero commit status entries in the currently accessible API surface. Therefore current-head CI remains **NOT VERIFIED**. The latest known successful Quality run is historical and does not satisfy the exact-head evidence rule.

The Quality workflow contains a manual `workflow_dispatch` path, but the available GitHub connector does not expose a workflow-dispatch action. No artificial source change is being introduced solely to manufacture a CI trigger.

## AI boundary
AI-1 remains SOURCE-VERIFIED. Current-head Quality CI is not verified. AI-2 Agent Core/provider integration/remote gateway/autonomous workflows remain blocked until the browser foundation and current AI-1 CI are validated.

## Release
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production releases remain blocked on runtime/release validation.

## Evidence rule
Never promote without evidence:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

## FIRST NEXT STEP — exactly one
**Obtain an exact-head Quality run for `3be7de126e6342a2ade388a897c5e51674acb018`; if green, perform only Android Scenario 1 and verify that the restored container uses the persisted UA before advancing to Scenarios 2–6.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`