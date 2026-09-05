# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `8421e0734578e2a88ef3c5a80bda600eb61ba9d7`
**Functional code checkpoint:** `8089e68a60f40cef6f36943fb8489e349290d951`

## Current product position
```text
Browser / Container / UA foundation
    per-container persistence + propagation                  DONE / source-verified
    restored session UA-before-restore lifecycle             SOURCE FIX / CI under validation
    Android Scenario 1                                        BLOCKED pending fresh runtime evidence

AI-1 Browser Tool
    specification / inventory / contracts                    DONE / source-verified
    registry / executor / focused tests                      SOURCE-VERIFIED
    exact-head Quality                                        RUN #92 in progress at source checkpoint
    Agent Core                                                 NOT STARTED / downstream

Privacy / Personal Product Hardening
    account callback/handoff legacy path                      REMOVED
    legacy snapshot-sync cluster                              REMOVED after reachability review
    active Firefox Sync                                      RETAINED
    background feed fetch/headless startup                    REMOVED
    QUERY_ALL_PACKAGES                                        REMOVED
    camera / mic / location / notification paths              RETAINED / justified
    storage/media permission attribution                       PENDING finer proof
    ACCESS_WIFI_STATE attribution                              PENDING stronger proof
    cleartext transport separation                             PENDING complete mapping
    local privacy/data-flow screen                             PENDING
```

## Current checkpoint
`ContainerUserAgentCreateSessionMiddleware` is the functional lifecycle correction. It creates the restored engine session, applies the persisted container UA before `restoreState()`, reapplies it defensively, and then dispatches `LinkEngineSessionAction`. The stale-state race hardening is at `8089e68a60f40cef6f36943fb8489e349290d951`.

The validation workflow was hardened in commits after the functional checkpoint. It now builds stable split APKs plus a debug APK, uploads SHA-named artifacts, installs the debug build into API 35, asserts package/process/resumed activity, checks the crash buffer, force-stops and relaunches, and preserves emulator logcat. It is configured for branch pushes, relevant pull requests, and manual dispatch.

## Runtime gate
Scenario 1 remains **FAIL / pending revalidation** from the prior physical-device observation:
- Container A restored;
- tab restored;
- configured Chrome/120 UA before process death;
- Gecko/Firefox 152 observed on restored navigation after relaunch;
- no usable Resume-last-tab control in the observed post-relaunch state.

Do not run Scenarios 2–6 until Scenario 1 passes.

## CI evidence
Quality run `33998587053` / #92 is the current relevant exact-source verification run for `ae5463fbd647b9a3ae9922f6578d2b3ed2c2480e`. AI-1 browser-tool tests, targeted container tests, Android NDK installation, and pinned native-source checkout have passed; native runtime build remains/was the active stage at the latest retrieval. No final Quality conclusion is claimed until the run completes.

The available GitHub connector exposes pull-request-triggered workflow runs and artifacts only when a run is retrievable; it does not expose workflow dispatch in this session. Therefore the current validation APK is **not yet artifact-verified** and no Android-runtime result is claimed.

## Release boundary
Historical validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. It is not evidence for the current functional checkpoint.

Production release remains blocked until:
1. current-source Quality is green;
2. a current-head Validation APK run is retrievable;
3. API-35 emulator smoke passes;
4. Android Scenario 1 proves persisted per-container UA survives restored session creation;
5. then Scenarios 2–6 are executed as the consolidated final runtime pass.

## AI boundary
AI-1 is the current minimal browser-control foundation. AI-2 Agent Core/provider integration/remote gateway/autonomous workflows remain downstream of runtime validation.

## FIRST NEXT STEP — exactly one
**Retrieve and verify a current-head Validation APK workflow run; download its artifact and inspect/test it before advancing beyond Scenario 1.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`