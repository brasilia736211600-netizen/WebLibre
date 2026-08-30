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
        v
REAL ANDROID RUNTIME PROOF                    [CURRENT BLOCKER]
        |
        +--> cold-start/restored UA            [NOT VERIFIED]
        +--> Container A/B UA isolation         [NOT VERIFIED]
        +--> Proxy A/B + fail-closed            [NOT VERIFIED]
        |
        v
RELEASE FOUNDATION
        |
        +--> final targeted validation          [PENDING]
        +--> split-ABI APK validation           [PENDING]
        |
        v
AI-1 Browser Tool API                         [NEXT MAJOR PHASE]
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
- `HistoryDelegateBindingMiddleware.kt` applies persisted UA at `LinkEngineSessionAction` and handles already-attached sessions via `AddTabAction`.
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

Existing release workflow builds the native gomobile runtime, then builds stable APKs and the stable app bundle. Stable APKs use the existing `build-browser` path; the intended release policy remains split-ABI (`android-arm`, `android-arm64`) with each APK independently publishable/downloadable. Release validation is pending the browser runtime milestone.

## AI ROADMAP

AI-0 specification: DONE.
AI-1 Browser Tool API: NOT STARTED.
AI-2 Agent Core: PENDING.
AI-3 Personal Profile + Memory: PENDING.
AI-4 Permission Engine: PENDING.
AI-5 First Workflows: PENDING.
AI-6 Advanced Personal Behavior: PENDING.
AI-7 Model/Provider Adapters: PENDING.
AI-8 End-to-End Validation: PENDING.

AI-1 must not bypass the browser foundation. The model will eventually operate through explicit browser tools and permission scopes, not unrestricted internal APIs.

## CI / EXECUTION CONTROL

The historical native CI prerequisite blocker is closed: the corrected Quality gate builds the pinned gomobile runtime before targeted native tests.

The repeated stale-run problem is also closed. `quality.yml` now uses per-PR/branch concurrency with `cancel-in-progress: true` and excludes itself from normal PR path triggers. This prevents old snapshots from consuming full gomobile/native builds when a newer commit arrives.

Parallel execution rule is mandatory: while an independent run/build waits, perform independent non-conflicting source/release/review/state analysis; never duplicate an active build and never write the same file concurrently.

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

## MASTER DEPENDENCY ORDER

```text
Android UA restore proof
 -> UA A/B runtime isolation
 -> Proxy A/B + fail-closed runtime proof
 -> final targeted validation
 -> split-ABI release validation
 -> AI-1 Browser Tool API
 -> AI-2 Agent Core
 -> AI-3 Profile + Memory
 -> AI-4 Permission Engine
 -> AI-5 workflows
 -> AI-6 advanced behavior
 -> AI-7 model adapters
 -> AI-8 end-to-end validation
 -> final release
```

## RESUME RULE

A new agent must read this map and `WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`, then verify actual GitHub branch/HEAD/PR/CI before editing. Treat a CI result as evidence only when its `head_sha` matches the checkpoint being evaluated. Follow:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Update this map and the short workflow state at every material milestone.

## CURRENT CHECKPOINT

**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD before this state commit:** `901bf4156b4b5b21bc8352c268b4e715ca73faa0`
**Latest product checkpoint with green Quality:** `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`
**PR:** #3, open, draft, base `main`.
**Latest verified Quality:** #39 `33329515686` — GREEN against product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
**Product-code change in this checkpoint:** none.
**Current blocker:** real Android runtime/device validation.
**Exact next step:** cold-start/restored-tab UA validation -> Container A/B isolation -> Proxy A/B/fail-closed -> release validation -> AI-1.
