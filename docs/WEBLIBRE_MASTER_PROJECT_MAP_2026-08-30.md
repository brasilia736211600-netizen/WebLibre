# WebLibre — Master Project Map

**Created:** 2026-08-30
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.
**Repository source of truth:** GitHub code, refs, commits, PRs, CI/build/release runs, artifacts, and release assets.
**Canonical execution state:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
**Canonical AI specification:** `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
**Canonical resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
**Canonical Android runtime checklist:** `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`
**UA/fingerprint product requirements:** `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`
**UA restore forensic record:** `docs/WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md`

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
        +--> cold-start restore UA              [RUNTIME FAIL]
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

Focused evidence:
- Dart container metadata suite: 11/11 green.
- Quality #39 `33329515686`: SUCCESS on the UA/container product checkpoint.

### Runtime contradiction and corrected source finding

The integrated ARM64 validation build proved that Container A can restore while its persisted UA is not applied to the restored navigation.

Actual current-branch inspection found the cold-start path in `GlobalComponents.restoreBrowserState(...)`:

`sessionStorage.restore -> RecoverableBrowserState -> tabsUseCases.restore -> RestoreCompleteAction`

That path is distinct from the normal `GeckoTabsApiImpl.addTab(...)` path where `session.settings.userAgentString = userAgent` is explicitly applied before navigation.

The repository **does already contain** a restore-binding implementation:
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/HistoryDelegateBindingMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStore.kt`

`Core.kt` installs the middleware before `EngineMiddleware`. On `LinkEngineSessionAction`, it reads the restored tab's `contextId`, looks up the existing per-profile `tab.db`, and applies `engineSession.settings.userAgentString` when a matching persisted UA is found.

The implementation was introduced by commits `435c1e8b...` and `64e196c6...`. Therefore the runtime failure does **not** prove that the restore hook is absent. It proves that the existing source-level hook is not producing the expected UA at runtime.

The current Pigeon `RecoverableTab` still carries `engineSessionStateJson` plus `TabState`; `TabState` has `contextId` but no UA. This is not the first fix target because the existing middleware was specifically designed to avoid needing a new recovery field.

The strongest unresolved boundary is one of: missing/wrong `contextId`, DB lookup failure/timing, UA assignment too late, or a different EngineSession producing the observed request. A dedicated forensic record tracks these hypotheses.

## ANDROID RUNTIME PROOF — BLOCKED AT SCENARIO 1

Repository inspection found no dedicated Android integration/runtime harness. The exact six-scenario procedure is recorded in `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

Scenario 1 result: **FAIL**.
- Before process death, Container A sent Chrome/120 UA.
- After process death/relaunch, Container A and its tab were restored, but the request-observed UA was `Mozilla/5.0 (Android 12; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0`.
- The post-relaunch screen directly showed the restored tab; no `Resume last tab` control was present then.

Scenarios 2–6 are intentionally blocked until the first causal Scenario 1 failure is fixed and revalidated.

## CURRENT DIAGNOSTIC CHANGE

A focused diagnostic was added to the existing restore hook and UA store. It records, at debug level:
- whether `LinkEngineSessionAction` reaches the middleware;
- `tabId` and `contextId`;
- whether an active profile context exists;
- whether the `tab.db` lookup is a hit, miss, missing-database case, or SQLite exception;
- whether setting `engineSession.settings.userAgentString` reports the expected effective value;
- elapsed time for the lookup/bind path.

This is diagnostic instrumentation only; it does not add a new persistence system or architecture.

## USER OBSERVATIONS / FUTURE PRODUCT DIRECTION

The first real-device pass also produced product observations that are now documented separately rather than implemented prematurely:
- The browser feels relatively heavy; this must be measured before optimization or feature removal.
- Previously visited pages should not be unnecessarily reloaded as new visits; cache/session/restore behavior must be measured before changing it.
- The current UA UX is too primitive and should evolve from raw-string editing toward coherent profile presets and expert customization.
- Desired profile dimensions include OS/platform, browser family and version, device/display characteristics, locale/timezone/geolocation, proxy/network, and supported fingerprint surfaces such as fonts, media devices, WebRTC, Canvas, WebGL, AudioContext, ClientRects, and navigator/hardware signals.
- The product should enforce coherent combinations rather than arbitrary impossible UA/fingerprint tuples.
- External benchmark research covers GoLogin, Multilogin, AdsPower, and Kameleo in `WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`.
- These requirements do not authorize implementing every commercial anti-detect feature. Only capabilities supported coherently by WebLibre's existing engine should be added, and only after the current runtime blocker is fixed.

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
7. `WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md` when diagnosing the current Scenario 1 blocker

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
**Current code checkpoint:** `2e3534c28787ab6bdaf00585e48e6384113bea77`.
**Runtime-tested APK source checkpoint:** `3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`.
**Manual stable Release:** Run `33341230075`, validation tag `validation-stable-5-3aa06cf6...`.
**Android runtime:** Scenario 1 FAIL — container/tab restore succeeded, per-container UA did not survive restored navigation.
**Diagnostic checkpoint:** `2e3534c28787ab6bdaf00585e48e6384113bea77`.
**First next step:** run focused CI/native checks for the diagnostic restore-boundary change; then produce one diagnostic ARM64 validation APK and inspect the restore-binding logs to identify the exact runtime failure branch before implementing any functional correction.
**Secondary product work after runtime blocker:** measure performance/reload behavior, then design the smallest coherent UA/profile editor from the requirements document.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
