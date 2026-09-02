# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `87a1011ebb3aa0d8ae86f2100c37855b135068fd`

## Current product position
```text
Browser / Container / UA foundation
    source + focused CI                         DONE / historical CI evidence only
    Android runtime restore UA                  FAIL — Scenario 1; source lifecycle stabilization committed, runtime revalidation pending

AI-1 Browser Tool
    specification / inventory / contracts       DONE / SOURCE-VERIFIED
    registry / executor / focused tests         SOURCE-VERIFIED; current Quality CI pending
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
    outbound app endpoint audit                 PARTIAL / Firefox Sync, Push, native fetch mapped
    remaining permission/cleartext audit        PENDING direct branch-scoped proof
    local privacy/data-flow screen             PENDING
```

## Latest completed cleanup
The legacy account compatibility route is now informational-only. The retired `AccountAuthRepository`, generated provider, `AccountAuthState`, generated state file, and legacy `AccountAuthStatusCard` were removed after the active account screen was reduced to a local informational route and no remaining known consumer was found. The retained account portal origin remains only for the existing subscription UI.

Active Firefox Sync remains separate and intact through Mozilla Android Components. UnifiedPush remains an intentional user-enabled background delivery path. Native fetch/download paths remain active browser functionality, so no speculative global `usesCleartextTraffic` removal was made.

## Android permission boundary
`INTERNET` and `ACCESS_NETWORK_STATE` remain justified. Foreground services remain backed by concrete DownloadService, PrivateTabsNotificationService, and MediaSessionService integrations. `ACCESS_WIFI_STATE` is still pending because the available code-search response is explicitly incomplete. Camera, microphone, location, media/storage and notifications still require direct consumer proof.

## Runtime blocker
Scenario 1 remains FAIL: restored Container A/tab used Gecko/Firefox 152 instead of the configured Chrome/120 UA after relaunch. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI boundary
AI-1 remains source-verified. Current-head CI is not verified. AI-2 must remain blocked until browser runtime foundation and current AI-1 CI are validated.

## Release
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production releases remain blocked on runtime/release validation.

## Evidence rule
Never promote:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

## FIRST NEXT STEP — exactly one
**Finish branch-scoped direct consumer proof for the remaining Android permissions and any remaining app-level HTTP/configuration consumers; then make only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
