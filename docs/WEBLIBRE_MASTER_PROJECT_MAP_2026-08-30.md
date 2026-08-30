# WebLibre — Master Project Map

**Created:** 2026-08-30
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.
**Repository source of truth:** GitHub code, branch refs, commits, PRs, and CI.
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
QUALITY GATE                                  [GREEN at verified checkpoints]
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
                      |
                      v
              AI-3 Personal Profile + Memory
                      |
                      v
              AI-4 Permission Engine
                      |
                      v
              AI-5 First Autonomous Workflows
                      |
                      v
              AI-6 Advanced Personal Behavior
                      |
                      v
              AI-7 Model / Provider Adapters
                      |
                      v
              AI-8 End-to-End Validation
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
- Quality #39 `33329515686`: GREEN on product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.

## ANDROID RUNTIME PROOF — PENDING

Repository inspection confirmed there is no dedicated `integration_test` Android runtime harness. The existing release workflow builds the native runtime and stable APK/AAB; Quality covers Flutter/native tests; neither proves real-device process-death or network behavior.

One consolidated device pass must prove:
1. cold-start/restored-tab UA persistence;
2. Container A/B UA isolation across open, duplicate, and restored tabs;
3. Restore isolation;
4. Proxy A/B isolation;
5. Proxy fail-closed behavior;
6. no cross-container mutation.

The exact procedure is recorded in:
`docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`

**Integrated validation artifact now exists:**
- Workflow run: `33337359647`
- Branch: `weblibre-ua-mainline-v3`
- Exact HEAD: `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`
- Build job: `99326557994` SUCCESS
- Stable APK build: SUCCESS
- Artifact: `weblibre-stable-apk-26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`
- Artifact id: `9739745969`
- Artifact SHA-256: `95e399057371d143e08784330280fb8b5106ffb4ec5dd06c35fe952d9703329f`
- Artifact not expired at last verification.

Do not require a new APK for each subtest.

## AI-1 — CURRENT

Preparation inventory:
`docs/WEBLIBRE_AI1_BROWSER_TOOL_INVENTORY_2026-08-30.md`

Implemented minimal model-independent registry and execution boundary:
- `apps/weblibre/lib/core/ai/tools/browser_tool_contract.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_registry.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_executor.dart`
- focused tests under `apps/weblibre/test/core/ai/tools/`

First slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Stable mappings:
- `get_tabs` -> `tabListProvider` + `tabStatesProvider`.
- `get_current_tab` -> `selectedTabProvider` + `tabStatesProvider`.
- `create_tab` -> existing `TabRepository.addTab` with `TabMode.regular`.
- `switch_tab` -> existing `TabRepository.selectTab`.
- `close_tab` -> existing `TabRepository.closeTab`.
- `open_url` -> existing `GeckoSessionService(tabId: ...).loadUrl`.

Execution boundary performs registry lookup, declared-permission checking, typed dispatch, deterministic success/error envelopes, and a non-persistent audit event. It does not execute LLM logic or expose Gecko/Pigeon/database internals.

Quality #65 exposed a concrete executor compile blocker; it was fixed in `91e9412a...`, and the deterministic unknown-tool path was hardened in `91e5e8d...`.
Quality #70 `33335945926` completed successfully against `f05f643...`; AI-1 browser tool tests and targeted container/native checks passed. AI-1 execution boundary is **CI-VERIFIED**.

No product-code changes were introduced by the later state/map/build documentation changes.

## RELEASE FOUNDATION

Existing release workflow builds the native gomobile runtime, then stable APKs/app bundle. Stable APKs use the existing split-ABI path (`android-arm`, `android-arm64`).

The manual `workflow_dispatch` path produces a validation APK artifact without publishing to Google Play. It now also creates a **GitHub prerelease validation Release** containing the generated APK assets directly. This makes each ABI APK independently downloadable from a GitHub Release asset instead of requiring extraction from a workflow-artifact ZIP.

For manual validation runs:
- stable creates a prerelease validation Release with both stable split-ABI APKs;
- alpha/alphaLegacy create a prerelease validation Release with their generated APKs;
- the release tag is unique per workflow run (`validation-<variant>-<run_number>-<sha>`);
- manual validation releases do not publish to Google Play.

For future production/stable publishing, the existing `v*` tag-triggered full release path continues to create the GitHub Release and attach stable APKs plus the AAB, then publish the AAB to Google Play internal track. No production version is declared stable until the Android runtime and release validation checkpoints are closed.

Manual-release asset implementation commit: `40abfb2a5f796e868bcd0ae0412ab521307166d2`.

The previous manual stable build `33337359647` predates this direct-release-asset step; its ZIP artifact remains valid for the already-built APK, but a new manual stable run is required to produce direct Release asset URLs.

## CI / EXECUTION CONTROL

The historical native prerequisite blocker is closed. Quality has per-PR/branch concurrency with `cancel-in-progress: true`.

Evidence rule: a CI/build run validates the workflow revision and exact checkout/head evidence captured at trigger time. Never use an old run to prove a later code checkpoint.

Parallel execution is mandatory: while a CI/build/run waits, perform independent non-conflicting source inspection, release analysis, or documentation. Never duplicate an active build, write the same file concurrently, bypass dependency order, or violate YAGNI.

## YAGNI / DO-NOT-REDO

Do not redo completed UA creation/UI/persistence/native propagation/restore/proxy/CI work unless focused evidence shows insufficiency.

Do not introduce global GeckoRuntime UA, `RecoverableTab.userAgent`, second DB, new recovery Pigeon field, event-arrival freshness heuristics, Android Components fork, or unrelated refactors.

For AI-1 do not introduce LLM/provider integration, memory, remote gateway, autonomous workflows, or full Agent Core. Wrap existing browser capabilities rather than replacing them.

## MASTER DEPENDENCY ORDER

```text
Browser runtime proof ─────────────────────────┐
                                               │
AI-1 inventory + contract + registry ──────────┤
                                               v
                                     minimal execution boundary
                                               |
                                     CI verification        [DONE]
                                               |
                                     integrated foundation
                                               |
                                     consolidated Android proof   [NEXT]
                                               |
                                     release validation
                                               |
                                     AI-2 Agent Core
                                               |
                                     AI-3 Profile + Memory
                                               |
                                     AI-4 Permission Engine
                                               |
                                     AI-5 workflows
                                               |
                                     AI-6 advanced behavior
                                               |
                                     AI-7 model adapters
                                               |
                                     AI-8 end-to-end validation
```

## RESUME / ANTI-AMNESIA RULES

A new agent must read:
1. `WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
2. `WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
3. `WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` when architecture/product scope is relevant
4. `WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
5. `WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md` before device validation

Then verify actual GitHub branch/HEAD/PR/CI before editing.

Evidence levels are strict:
- `SOURCE-VERIFIED`: repository code path inspected.
- `CI-VERIFIED`: relevant run completed successfully and `head_sha` exactly matches the checkpoint under evaluation.
- `ANDROID-RUNTIME-VERIFIED`: behavior exercised on a real Android runtime.
- `DOCUMENTED`: recorded state only.

Never promote a lower evidence level to a higher one. Never trust a remembered HEAD, an old PR description, or a stale CI result. If chat and repository disagree, GitHub wins.

Follow:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Update this map and workflow state at every material milestone. Save exact HEAD, test evidence, CI run/head_sha, remaining blocker, and first next step.

## CURRENT CHECKPOINT

**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** after the workflow commit `40abfb2...` and this documentation synchronization; verify the exact branch HEAD before the next execution.
**AI-1:** CI-VERIFIED via Quality #70 `33335945926` against `f05f643...`.
**Manual stable APK:** previous SUCCESS via Flutter CICD run `33337359647`, exact head `26e96cfc...`; previous artifact `9739745969` is ZIP-only and predates direct Release asset publishing.
**Direct APK Release assets:** workflow support is now implemented but **not yet CI-verified** on a fresh manual run.
**Runtime status:** consolidated six-scenario real-device validation is pending.
**Browser blocker:** real Android runtime validation.
**First next step:** run a fresh manual `stable` Flutter CICD on `weblibre-ua-mainline-v3`; verify build, GitHub validation Release, both direct APK assets, asset names, and `head_sha`. Then use the ARM64 asset for the consolidated Android runtime checklist.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
