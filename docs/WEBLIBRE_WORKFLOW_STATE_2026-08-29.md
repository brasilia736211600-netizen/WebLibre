# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD:** `4c222edec7fc198d2492c69dbf77e76a78838e8d`

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code, branch refs, commits, PRs, and CI. Do not reconstruct state from chat.

### Browser / UA
Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal/multi/duplicate UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted UA by `contextualIdentity` from existing profile-scoped `tab.db`.
- `HistoryDelegateBindingMiddleware.kt` applies persisted container UA for `LinkEngineSessionAction` and handles already-attached sessions through `TabListAction.AddTabAction`.
- Native creation paths apply UA to the prepared `EngineSession` before first navigation.
- No global GeckoRuntime UA, `_freshSnapshotPending` heuristic, second DB, new recovery Pigeon field, or Android Components fork.

### Restore
UA cold-start/restored-tab integration is implemented in source but remains runtime-unverified. Restore retains `contextId`; no `RecoverableTab.userAgent` field was added. Existing `tab.db` and persisted `container.metadata` remain the sources of truth.

### Test surface
- Dart focused container metadata test: 11/11 green in the last verified Quality gate.
- Native focused tests: `ContainerUserAgentStoreTest` and `ContainerProxyFeatureTest`.
- `ContainerUserAgentStoreTest` covers matching container, different container, blank UA, and malformed metadata.
- There is no dedicated automated Android process-death/cold-start test; unit tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch HEAD: `4c222edec7fc198d2492c69dbf77e76a78838e8d` (`docs: add parallel execution rule to project map`).
- Parent state checkpoint: `ef9a08005b1c9ea4c15814b5c9f8aef85a90378c`.
- PR #3: open, draft, not merged; base `main`.
- Latest verified Quality run: #29 `33327113039` for HEAD `fb09b904...` — SUCCESS.
- Quality #29 passed Dart targeted tests, Android NDK setup, pinned native source checkout, gomobile runtime build, Gradle setup, and targeted native `ContainerUserAgentStoreTest` + `ContainerProxyFeatureTest`.
- Quality #32 `33328637149` is the current live verification run for the documentation checkpoints; at the last observed point it had passed Dart, NDK setup, and native source checkout and was building the gomobile runtime.
- Previous Quality #24/#25 failed before native tests because `weblibre-go.aar` was missing; the minimal CI-only prerequisite repair was completed in `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1` and validated by #29.
- No product-code change has been made while waiting on runtime/CI proof.

## LAST COMPLETED STEP
Closed the CI/AAR blocker with Quality #29 green, established the durable master project map, and added a durable parallel-execution rule so independent work continues while CI/build runs are waiting.

## CURRENT UNFINISHED STEP
Real Android runtime/device validation remains: cold-start/restored-tab UA persistence, simultaneous Container A/B UA isolation, and Proxy A/B/fail-closed runtime behavior.

## EXACT NEXT EXECUTION
1. While CI/build/test runs are pending, perform independent non-conflicting source/release/PR analysis rather than idling.
2. Reconcile the live CI result when it completes; fix only the first concrete causal failure, if any.
3. Perform real Android cold-start/restored-tab UA validation using the current build.
4. Verify simultaneous Container A/B UA isolation across open, duplicate, and restored tabs.
5. Verify Proxy A/B runtime behavior and fail-closed behavior.
6. Re-run focused Dart/native gates after any runtime findings.
7. Validate existing `build-browser --split-per-abi` release path for supported `android-arm,android-arm64` artifacts and publish each APK independently.
8. Only after the browser milestone is stable, begin AI-1 Browser Tool API.

## PARALLEL EXECUTION RULE
When any independent CI/build/test/run is waiting or in progress, do not remain idle. Use the waiting interval for independent, non-conflicting work such as source/call-chain inspection, PR/review/issue inspection, release/build-script analysis, documentation consistency, or preparation of the next minimal change.

Rules:
1. Only run logically independent tasks alongside the active run.
2. Never perform two writes against the same file or dependent code path concurrently.
3. Never duplicate an active test/build unless there is a concrete diagnostic reason.
4. Prefer read/analysis/review work while CI executes.
5. Reconcile parallel findings with the active run result before modifying code.
6. Do not bypass dependency order or YAGNI.
7. If parallel work exposes a concrete blocker, fix only the first causal blocker and stop unrelated work.
8. Save material results to the durable state files before handoff.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, or unrelated refactors unless a focused runtime/test result proves the current path insufficient.

## MASTER PROJECT MAP
`docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` is the durable high-level roadmap. Update it on every material milestone; keep this file as the short execution truth.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `4c222edec7fc198d2492c69dbf77e76a78838e8d`
**Product code changed in this checkpoint:** no.
**CI:** Quality #29 `33327113039` green; Quality #32 `33328637149` was still in progress at last observation.
**Current blocker:** real Android runtime/device validation.
**Exact next step:** keep using parallel independent work while runs are pending; reconcile CI; then cold-start/restored-tab UA validation -> Container A/B isolation -> Proxy A/B/fail-closed -> final validation -> split-ABI release validation -> AI-1.
