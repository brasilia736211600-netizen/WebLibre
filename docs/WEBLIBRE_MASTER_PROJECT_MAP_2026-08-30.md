# WebLibre — Master Project Map

**Created:** 2026-08-30
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.
**Repository source of truth:** GitHub code, refs, commits, PRs, CI/build/release runs, artifacts, and release assets.
**Canonical execution state:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
**Canonical AI specification:** `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
**Canonical resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
**Canonical Android runtime checklist:** `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`

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
        +--> restore-source integration         [DONE IN SOURCE]
        |
        v
QUALITY GATE
        |
        +-----------------------------+
        |                             |
        v                             v
REAL ANDROID RUNTIME PROOF       AI-1 BROWSER TOOL
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
              INTEGRATED FOUNDATION
                      |
                      v
              CONSOLIDATED ANDROID PROOF  [NEXT]
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

## ANDROID RUNTIME PROOF — PENDING

Repository inspection found no dedicated Android integration/runtime harness. The exact six-scenario procedure is recorded in `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

Scenarios:
1. cold-start/restored-tab UA persistence;
2. Container A/B UA isolation across open, duplicate, and restore;
3. restore isolation;
4. Proxy A/B isolation;
5. Proxy fail-closed;
6. no cross-container mutation.

One integrated APK is used for the whole pass; do not rebuild per scenario.

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

The existing build workflow now supports manual `workflow_dispatch` for `stable`, `alpha`, and `alphaLegacy`. Manual validation builds do not publish to Google Play.

The workflow also contains a direct GitHub prerelease asset path for manual validation builds. The intended direct assets are:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

The prior manual run `33337359647` succeeded against `26e96cfc...` and produced ZIP artifact `9739745969`, but it predates the direct Release-asset path. Therefore it is **ARTIFACT-VERIFIED**, not **RELEASE-ASSET-VERIFIED**.

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

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Update Master Map and Workflow State at every material milestone with exact HEAD, evidence, CI/build/release identifiers, blockers, and one first next step.

## CURRENT CHECKPOINT

**Date:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Latest durable code/build checkpoint:** `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
**Resume protocol hardening commit:** `1e4d0fad28e7d675036fc3db91995f8f528d0e6c`.
**Runtime checklist sync:** `ce6c37aab84c9fac520c4395fa1c3630380d1692`.
**AI-1:** CI-VERIFIED via Quality #70 `33335945926` against `f05f643...`.
**Manual stable build:** SUCCESS via `33337359647` at `26e96cfc...`; ZIP artifact `9739745969` exists.
**Direct Release assets:** workflow implementation is present but needs a fresh manual run after the workflow change before it can be marked RELEASE-ASSET-VERIFIED.
**Android runtime:** six scenarios pending.
**First next step:** run fresh manual `stable` Flutter CICD on `weblibre-ua-mainline-v3`, verify direct Release assets by exact run/head/step/asset evidence, then use the ARM64 asset for the consolidated Android runtime pass.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
