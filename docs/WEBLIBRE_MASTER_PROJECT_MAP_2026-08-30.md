# WebLibre — Master Project Map

**Created:** 2026-08-30
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.
**Repository source of truth:** GitHub code, branch refs, commits, PRs, and CI.
**Canonical execution state:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
**Canonical AI specification:** `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

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
QUALITY GATE                                  [GREEN]
        |
        +-----------------------------+
        |                             |
        v                             v
REAL ANDROID RUNTIME PROOF       AI-1 PREPARATION
        |                        (inventory/contract)
        |                             |
        +-------------+---------------+
                      |
                      v
              INTEGRATED FOUNDATION
                      |
                      v
              RELEASE VALIDATION
                      |
                      v
              AI-1 Browser Tool API
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

## BROWSER / UA MILESTONE — COMPLETED SOURCE + FOCUSED CI

Implemented and verified at source level:
- `ContainerMetadata.userAgent` persistence, serialization, equality, normalization.
- `AddTabParams.userAgent` contract and generated bindings.
- Normal, multi-add, and duplicate-tab UA propagation.
- Existing per-container UA UI.
- Native UA application to the prepared `EngineSession` before first navigation.
- `ContainerUserAgentStore.kt` resolves persisted UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` applies UA at restore/session creation using existing state sources.
- Restore path retains `contextId` and uses existing persisted container metadata; no second DB or `RecoverableTab.userAgent` was added.

Focused evidence:
- Dart container metadata suite: 11/11 green.
- Quality #39 `33329515686`: GREEN on product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- Quality #39 passed Dart targeted tests, Android NDK installation, pinned native source checkout, gomobile runtime build, Gradle setup, `ContainerUserAgentStoreTest`, and `ContainerProxyFeatureTest`.

Important: this does NOT prove Android process-death/cold-start behavior.

## RESTORE / PROXY — REMAINING RUNTIME PROOF

The remaining proof must be performed on an actual Android runtime/device:

1. Cold-start/restored-tab UA persistence.
2. Simultaneous Container A/B UA isolation across open, duplicate, and restored tabs.
3. Proxy A/B isolation and fail-closed behavior.
4. Regression that changes in A cannot mutate B.

Do not rewrite the existing restore or proxy architecture without a focused failure proving it insufficient.

## RELEASE FOUNDATION

Existing release workflow builds the native gomobile runtime, then builds stable APKs and the stable app bundle. Stable APKs use the existing `build-browser` path; the intended release policy remains split-ABI (`android-arm`, `android-arm64`) with each APK independently publishable/downloadable. Release validation is pending the integrated browser runtime milestone.

## AI ROADMAP

AI-0 specification: DONE.
AI-1 preparation/inventory: STARTED.
AI-1 Browser Tool implementation: NOT STARTED.
AI-2 Agent Core: PENDING.
AI-3 Personal Profile + Memory: PENDING.
AI-4 Permission Engine: PENDING.
AI-5 First Workflows: PENDING.
AI-6 Advanced Personal Behavior: PENDING.
AI-7 Model/Provider Adapters: PENDING.
AI-8 End-to-End Validation: PENDING.

AI-1 preparation artifact:
`docs/WEBLIBRE_AI1_BROWSER_TOOL_INVENTORY_2026-08-30.md`

The first minimal tool slice identified from existing source is:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

No model, memory, remote transport, or unrestricted internal API exposure has been implemented.

## CI / EXECUTION CONTROL

The historical native CI prerequisite blocker is closed: the corrected Quality gate builds the pinned gomobile runtime before targeted native tests.

The repeated stale-run problem is closed: `quality.yml` uses per-PR/branch concurrency with `cancel-in-progress: true` and excludes itself from normal PR path triggers.

Parallel execution is mandatory. Android device testing is a consolidated validation checkpoint, not a prerequisite for independent repository preparation. While a run/build waits, complete independent source inspection, contract preparation, release analysis, and documentation work. Do not duplicate builds or write the same file concurrently.

## YAGNI / DO-NOT-REDO

Do not redo completed container/UA creation, UI, persistence, native propagation, restore architecture, proxy architecture, or CI prerequisite work unless focused evidence shows regression/insufficiency.

Do not introduce:
- global GeckoRuntime UA;
- `RecoverableTab.userAgent`;
- a second persistence DB;
- a new Pigeon recovery field;
- event-arrival freshness heuristics such as `_freshSnapshotPending`;
- an Android Components fork;
- unrelated refactors.

For AI, do not introduce an LLM/provider, memory system, remote gateway, or full Agent Core before the minimal Browser Tool boundary is established and tested.

## MASTER DEPENDENCY ORDER

```text
Browser runtime proof ─────────────────────┐
                                           │
AI-1 inventory/contract preparation ───────┤
                                           v
                                    integrated foundation
                                           |
                                    release validation
                                           |
                                    AI-1 tool registry
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
                                           |
                                    final release
```

## RESUME RULE

A new agent must read this map and `WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`, then verify actual GitHub branch/HEAD/PR/CI before editing. Treat a CI result as evidence only when its `head_sha` matches the checkpoint being evaluated. Follow:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Update this map and the short workflow state at every material milestone.

## CURRENT CHECKPOINT

**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Last known product checkpoint:** `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
**Latest verified Quality:** #39 `33329515686` — GREEN against the product checkpoint.
**Latest change:** AI-1 source inventory/preparation documentation only.
**Android runtime proof:** pending; will be consolidated into one final device validation pass rather than repeated downloads for each subtest.
**Exact parallel next steps:** verify exact existing APIs for the six-tool AI-1 slice; prepare consolidated Android validation/build path; then implement only the minimal typed tool contract/registry if the existing APIs are stable.
