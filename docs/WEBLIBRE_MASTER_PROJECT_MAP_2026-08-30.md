# WebLibre — Master Project Map

**Created:** 2026-08-30
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.
**Repository source of truth:** GitHub code, branch refs, commits, PRs, and CI.
**Canonical execution state:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
**Canonical AI specification:** `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
**Canonical resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`

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
        |                        +--> focused tests   [WRITTEN]
        |                        +--> API mapping     [SOURCE-VERIFIED]
        |                        +--> execution       [SOURCE-VERIFIED]
        |                        +--> CI coverage     [ADDED; RUN PENDING]
        |                             |
        +-------------+---------------+
                      v
              INTEGRATED FOUNDATION
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
- Quality #60 `33334955774`: GREEN against `477140419642d1170b241dd39f143900b9b98909`; this run did not yet contain the newly added AI-1 test step, so it is not AI-1 CI proof.

## ANDROID RUNTIME PROOF — PENDING

One consolidated device pass must prove:
1. cold-start/restored-tab UA persistence;
2. Container A/B UA isolation across open, duplicate, and restored tabs;
3. Proxy A/B isolation and fail-closed behavior;
4. no cross-container mutation.

Do not require a new APK for each subtest.

## AI-1 — CURRENT

Preparation inventory:
`docs/WEBLIBRE_AI1_BROWSER_TOOL_INVENTORY_2026-08-30.md`

Implemented minimal model-independent registry:
- `apps/weblibre/lib/core/ai/tools/browser_tool_contract.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_registry.dart`
- `apps/weblibre/test/core/ai/tools/browser_tool_registry_test.dart`

First slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Source-verified stable mappings:
- `get_tabs` -> `tabListProvider` + `tabStatesProvider`.
- `get_current_tab` -> `selectedTabProvider` + `tabStatesProvider`.
- `create_tab` -> existing `TabRepository.addTab` with `TabMode.regular`.
- `switch_tab` -> existing `TabRepository.selectTab`.
- `close_tab` -> existing `TabRepository.closeTab`.
- `open_url` -> existing `GeckoSessionService(tabId: ...).loadUrl`.

Minimal execution boundary:
`apps/weblibre/lib/core/ai/tools/browser_tool_executor.dart`

Focused execution tests:
`apps/weblibre/test/core/ai/tools/browser_tool_executor_test.dart`

The execution boundary performs registry lookup, declared-permission checking, typed dispatch, deterministic success/error envelopes, and a non-persistent audit event. It does not execute LLM logic or expose Gecko/Pigeon/database internals.

CI coverage was added to `.github/workflows/quality.yml` for both AI-1 focused test files. The workflow-only commit does not automatically create a new PR Quality run under the current trigger/path behavior; therefore AI-1 remains CI-unverified until a Quality run actually executes those tests.

## RELEASE FOUNDATION

Existing release workflow builds the native gomobile runtime, then stable APKs/app bundle. Stable APKs use the existing split-ABI path (`android-arm`, `android-arm64`). Release validation follows integrated browser/runtime readiness.

## CI / EXECUTION CONTROL

The historical native prerequisite blocker is closed. Quality has per-PR/branch concurrency with `cancel-in-progress: true`, and normal PR triggers cover product paths while `workflow_dispatch` is available.

Important evidence rule: Quality #60 proves only the tests present in that run. Because the AI-1 test step was added afterward, #60 cannot be retroactively used as AI-1 proof.

Parallel execution is mandatory: while a CI/build/run waits, perform independent source inspection, contract work, release analysis, or documentation. Never duplicate an active build, write the same file concurrently, bypass dependency order, or violate YAGNI.

Android testing is a consolidated validation checkpoint, not a prerequisite for independent repository preparation.

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
                                     CI verification
                                               |
                                     integrated foundation
                                               |
                                     consolidated Android proof
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
**Current HEAD before this documentation update:** `b6c866d2e372c2af1ff45b52003a6b469f4f8229`.
**Quality #60:** `33334955774` GREEN against `477140419642d1170b241dd39f143900b9b98909`; not AI-1 CI proof because AI-1 test coverage was added afterward.
**AI-1 CI coverage:** added in `b6c866d2e372c2af1ff45b52003a6b469f4f8229`; a new Quality run executing that step is required.
**Android runtime proof:** pending; consolidate into one device pass.
**AI-1:** contract/registry + source-verified six-tool mappings + minimal execution boundary + focused tests implemented; CI coverage now present, execution proof pending.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.