# WebLibre — Master Project Map

**Created:** 2026-08-30
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.
**Repository source of truth:** GitHub code, refs, commits, PRs, CI/build/release runs, artifacts, and release assets.
**Canonical execution state:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
**Canonical AI specification:** `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
**Canonical resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
**Canonical Android runtime checklist:** `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`
**UA/fingerprint product requirements:** `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`

## CURRENT POSITION

```text
CONTAINER + PRIVACY FOUNDATION
        |
        v
PER-CONTAINER USER-AGENT
        |
        +--> persistence / serialization        [DONE]
        +--> normal / multi / duplicate         [DONE]
        +--> native pre-navigation UA           [DONE]
        +--> container UA UI                    [DONE]
        +--> restore-source integration         [SOURCE-VERIFIED, RUNTIME-CONTRADICTED]
        |
        v
QUALITY GATE
        |
        +-----------------------------+
        |                             |
        v                             v
REAL ANDROID RUNTIME PROOF       AI-1 BROWSER TOOL
        |                             |
        |  Scenario 1 FAIL             |
        |  restore UA mismatch         |
        |                             |
        |                        +--> inventory       [DONE]
        |                        +--> typed registry  [DONE]
        |                        +--> focused tests   [DONE]
        |                        +--> API mapping     [SOURCE-VERIFIED]
        |                        +--> execution       [SOURCE-VERIFIED]
        |                        +--> CI coverage     [DONE]
        |                        +--> CI execution    [GREEN / VERIFIED]
        |                             |
        +-------------+---------------+
                      v
              FIX + REVALIDATE SCENARIO 1
                      |
                      v
              CONSOLIDATED ANDROID PROOF
                      |
                      v
              RELEASE VALIDATION
                      |
                      v
              AI-2 Agent Core
```

## BROWSER / UA MILESTONE

Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence, serialization, equality, normalization.
- `AddTabParams.userAgent` contract and generated bindings.
- Normal, multi-add, and duplicate-tab UA propagation.
- Existing per-container UA UI.
- Native UA application to the prepared `EngineSession` before first navigation.
- `ContainerUserAgentStore.kt` resolves persisted UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` applies UA at restore/session creation using existing state sources.
- Restore retains `contextId`; no second DB or `RecoverableTab.userAgent` was added.

Focused evidence:
- Dart container metadata suite: 11/11 green.
- Quality #39 `33329515686`: SUCCESS on the UA/container product checkpoint.

**Runtime contradiction discovered:** on the integrated ARM64 validation build, Container A restored after process death, but its network-observed UA changed from the configured Chrome/120 UA to the default Gecko/152 Firefox UA. Therefore the source-verified restore claim is not sufficient for runtime proof and must be debugged before proceeding.

## ANDROID RUNTIME PROOF — BLOCKED AT SCENARIO 1

Repository inspection found no dedicated Android integration/runtime harness. The exact six-scenario procedure is recorded in `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

Scenario 1 result: **FAIL**.
- Before process death, Container A sent Chrome/120 UA.
- After process death/relaunch, Container A and its tab were restored, but the request-observed UA was `Mozilla/5.0 (Android 12; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0`.
- The post-relaunch screen directly showed the restored tab; no `Resume last tab` control was present then.

Scenarios 2–6 are intentionally blocked until the first causal Scenario 1 failure is fixed and revalidated.

## USER OBSERVATIONS / FUTURE PRODUCT DIRECTION

The first real-device pass also produced product observations that are now documented separately rather than implemented prematurely:
- The browser feels relatively heavy; this must be measured before optimization or feature removal.
- Previously visited pages should not be unnecessarily reloaded as new visits; cache/session/restore behavior must be measured before changing it.
- The current UA UX is too primitive and should evolve from raw-string editing toward coherent profile presets and expert customization.
- Desired profile dimensions include OS/platform, browser family and version, device/display characteristics, locale/timezone/geolocation, proxy/network, and supported fingerprint surfaces such as fonts, media devices, WebRTC, Canvas, WebGL, AudioContext, ClientRects, and navigator/hardware signals.
- The product should enforce coherent combinations rather than arbitrary impossible UA/fingerprint tuples.
- The external benchmark research covers GoLogin, Multilogin, AdsPower, and Kameleo and is recorded in `WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`.
- These requirements do **not** authorize implementing every commercial anti-detect feature. Only capabilities supported coherently by WebLibre's existing engine should be added, and only after the current runtime blocker is fixed.

## AI-1

First slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Implementation:
- `apps/weblibre/lib/core/ai/tools/browser_tool_contract.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_registry.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_executor.dart`
- focused tests under `apps/weblibre/test/core/ai/tools/`

Quality #70 `33335945926` succeeded against `f05f643...`; AI-1 execution boundary is CI-VERIFIED. Do not expand AI-1 without evidence of insufficiency.

## RELEASE / ARTIFACT FOUNDATION

The existing build workflow supports manual `workflow_dispatch` for `stable`, `alpha`, and `alphaLegacy`. Manual validation builds do not publish to Google Play.

The workflow also contains a direct GitHub prerelease asset path for manual validation builds. The intended direct assets are:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Manual Flutter CICD `33341230075` succeeded at `3aa06cf6...` and produced validation Release `validation-stable-5-3aa06cf6...` with both direct APK assets. This is RELEASE-ASSET-VERIFIED for that exact build and is the APK used for the runtime Scenario 1 test.

Future production/stable releases continue using the existing `v*` path, attaching split-ABI APKs plus AAB and publishing the AAB to Google Play internal track only after Android runtime and release validation are complete.

## CI / RELEASE EVIDENCE GATE

A CI/build/release result is accepted only after verifying:

```text
intended change
 -> commit SHA
 -> workflow revision contains change
 -> run branch/ref
 -> run.head_sha == intended SHA
 -> required job SUCCESS
 -> required step SUCCESS (not SKIPPED)
 -> expected artifact/release exists
 -> exact asset names/URLs/checksum verified
```

A successful older run cannot prove a later workflow change. A ZIP artifact does not prove direct Release assets.

## RESUME / ANTI-AMNESIA RULES

Every new agent must read:
1. `WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
2. `WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
3. `WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` when architecture/product scope is relevant
4. `WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
5. `WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md` before device validation
6. `WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md` when UA/profile/performance product scope is being discussed

Then verify actual branch/HEAD/PR/CI/build/release/assets before editing.

Evidence levels:
- `SOURCE-VERIFIED`
- `CI-VERIFIED`
- `ANDROID-RUNTIME-VERIFIED`
- `ARTIFACT-VERIFIED`
- `RELEASE-ASSET-VERIFIED`
- `DOCUMENTED`

Never promote a lower evidence level to a higher one. `[x]` is documentation only.

## YAGNI / DO-NOT-REDO

Do not redo completed UA/container/proxy/AI-1 work unless focused evidence proves insufficiency.
Do not add global GeckoRuntime UA, `RecoverableTab.userAgent`, second DB, new recovery Pigeon fields, event-arrival freshness heuristics, Android Components fork, LLM/provider integration, memory, remote gateway, or unrelated refactors without evidence.

Do not remove browser features merely because the APK feels large. First measure APK composition, native/runtime contributions, startup, memory, and feature usage.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Update Master Map and Workflow State at every material milestone with exact HEAD, evidence, CI/build/release identifiers, blockers, and one first next step.

## CURRENT CHECKPOINT

**Date:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `b46839006e412d67574f1af4d8d00aa6efdb4bb4`.
**Runtime-tested APK source checkpoint:** `3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`.
**Manual stable Release:** Run `33341230075`, validation tag `validation-stable-5-3aa06cf6...`.
**Android runtime:** Scenario 1 FAIL — container/tab restore succeeded, per-container UA did not survive restored navigation.
**New product-requirements checkpoint:** `dec34fa60cbf8b2c17d91339cd646d8a32260a98`.
**First next step:** inspect the existing restore/session UA call chain at the actual branch HEAD and identify the first causal point where the persisted container UA is lost; implement only a minimum correction if source evidence proves it necessary, then focused-test and revalidate Scenario 1 before any other runtime scenario.
**Secondary product work after runtime blocker:** measure performance/reload behavior, then design the smallest coherent UA/profile editor from the requirements document.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
