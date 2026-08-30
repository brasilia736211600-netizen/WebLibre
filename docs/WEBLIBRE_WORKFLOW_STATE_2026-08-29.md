# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD:** `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code, branch refs, commits, PRs, and CI. Never reconstruct state from chat.

### Browser / UA
Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal/multi/duplicate UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted container UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` applies persisted UA at `LinkEngineSessionAction` and handles already-attached sessions through `AddTabAction`.
- Native creation paths apply UA to the prepared `EngineSession` before first navigation.
- No global GeckoRuntime UA, second DB, new recovery Pigeon field, or Android Components fork.

### Restore
UA cold-start/restored-tab integration is implemented in source but remains runtime-unverified. Restore retains `contextId`; existing `tab.db` and persisted `container.metadata` remain the sources of truth.

### Test surface
- Dart focused container metadata tests: 11/11 green.
- Native focused tests: `ContainerUserAgentStoreTest` and `ContainerProxyFeatureTest`.
- Quality #39 completed successfully with Dart tests, NDK setup, pinned native checkout, gomobile runtime build, Gradle setup, and both targeted native tests green.
- There is no automated Android process-death/cold-start test; unit tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch/PR HEAD: `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- PR #3: open, draft, not merged; base `main`.
- Quality #39 `33329515686`: **SUCCESS** against HEAD `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- Quality #39 steps all relevant to the gate passed: Dart targeted tests, Android NDK, native source pin verification, gomobile runtime build, Gradle setup, `ContainerUserAgentStoreTest`, `ContainerProxyFeatureTest`.
- Older Quality runs must not be treated as evidence for the current HEAD unless their `head_sha` matches it.
- Quality workflow uses per-PR/branch `concurrency` with `cancel-in-progress: true`, and excludes `.github/workflows/quality.yml` from normal PR path triggers. This prevents stale overlapping runs and workflow-only churn.
- No product-code change was required by the CI duplication issue.

## RUN INTERPRETATION RULE
A Quality run validates the `head_sha` captured at trigger time, not the branch HEAD seen later. Always inspect `head_sha` before using a result as current evidence.

## LAST COMPLETED STEP
Closed the CI prerequisite/scheduling problems and obtained a fully green Quality #39 on the current product checkpoint. Product code is green at the focused Dart/native gate.

## CURRENT UNFINISHED STEP
Real Android runtime/device validation: cold-start/restored-tab UA persistence, simultaneous Container A/B UA isolation, and Proxy A/B/fail-closed runtime behavior.

## EXACT NEXT EXECUTION
1. Do not create another Quality run for docs-only state changes.
2. Perform real Android cold-start/restored-tab UA validation using the current build.
3. Verify simultaneous Container A/B UA isolation across open, duplicate, and restored tabs.
4. Verify Proxy A/B runtime behavior and fail-closed behavior.
5. Re-run focused Dart/native gates only after runtime findings or source changes.
6. Validate the existing `build-browser --split-per-abi` release path for supported `android-arm,android-arm64` artifacts.
7. Only after the browser milestone is stable, begin AI-1 Browser Tool API.

## PARALLEL EXECUTION RULE
When an independent CI/build/test/run is waiting or in progress, do not remain idle. Use the interval for independent non-conflicting source/call-chain inspection, PR/review/issue inspection, release/build analysis, documentation consistency, or preparation of the next minimal change.

Rules:
1. Only run logically independent tasks alongside the active run.
2. Never perform two writes against the same file or dependent code path concurrently.
3. Never duplicate an active test/build without a concrete diagnostic reason.
4. Prefer read/analysis/review while CI executes.
5. Reconcile parallel findings with the active run before modifying code.
6. Never bypass dependency order or YAGNI.
7. If parallel work exposes a concrete blocker, fix only the first causal blocker.
8. Save material results to durable state before handoff.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, an Android Components fork, or unrelated refactors unless focused runtime/test evidence proves the current path insufficient.

## MASTER PROJECT MAP
`docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` is the durable high-level roadmap. Update it on every material milestone.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`
**Product code changed in this checkpoint:** no.
**CI state:** Quality #39 `33329515686` GREEN.
**Current blocker:** real Android runtime/device validation.
**Exact next step:** cold-start/restored-tab UA validation -> Container A/B isolation -> Proxy A/B/fail-closed -> release validation -> AI-1.
