# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD:** `fb09b904e196fd56b8e2ab8436aafae38d7d0337`

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code/PR/CI. Do not reconstruct state from chat.

### Browser / UA
Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal/multi/duplicate tab UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted UA by `contextualIdentity` from existing profile-scoped `tab.db`.
- `HistoryDelegateBindingMiddleware.kt` applies persisted container UA for `LinkEngineSessionAction` and handles already-attached sessions through `TabListAction.AddTabAction`.
- No global GeckoRuntime UA, `_freshSnapshotPending` heuristic, second DB, new recovery Pigeon field, or Android Components fork.

### Restore
UA cold-start/restored-tab integration is implemented in source but remains runtime-unverified. Restore retains `contextId`; no `RecoverableTab.userAgent` field was added. Existing `tab.db` and persisted `container.metadata` remain the sources of truth.

### Test surface
- Dart focused container metadata test exists at `apps/weblibre/test/features/geckoview/features/tabs/data/models/container_data_test.dart`.
- Native focused tests exist for `ContainerUserAgentStoreTest` and `ContainerProxyFeatureTest`.
- `ContainerUserAgentStoreTest` covers matching container, different container, blank UA, and malformed metadata.
- There is no dedicated automated Android process-death/cold-start test in the current focused Dart model test directory; unit tests alone cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Actual branch HEAD: `fb09b904e196fd56b8e2ab8436aafae38d7d0337` (`docs: record green native gate and runtime-validation next step`).
- PR #3: open, draft, not merged; base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- Branch ref is authoritative when PR body text lags the branch.
- Current branch is 83 commits ahead of the merge base and 2 commits behind current `main`; compare is divergent because `main` advanced after the PR base.
- Quality #29 `33327113039` for HEAD `fb09b904...`: **SUCCESS**.
- Quality #29 job `99299103742`: Dart targeted tests passed; Android NDK installation passed; pinned native runtime sources checkout passed; gomobile runtime build passed; Gradle setup passed; targeted native `ContainerUserAgentStoreTest` + `ContainerProxyFeatureTest` passed.
- Previous Quality #24 `33326192759` and #25 `33326217737` failed before native tests because `weblibre-go.aar` was missing. The CI-only prerequisite repair was already completed in commit `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1` and is now validated by the green #29 run.
- No product-code change is required from the CI result.

## LAST COMPLETED STEP
Completed and independently verified the corrected CI gate through the current branch HEAD: Quality #29 passed the Dart gate, gomobile runtime preparation, Gradle setup, and both targeted native container test classes. This closes the previous CI/AAR blocker.

## CURRENT UNFINISHED STEP
Real Android runtime/device validation remains. Specifically, cold-start/restored-tab UA persistence and simultaneous Container A/B UA isolation are still not proven at runtime. Proxy A/B runtime regression/fail-closed behavior is also still not proven at runtime.

## EXACT NEXT EXECUTION
1. Perform a real Android cold-start/restored-tab validation using the current APK/testable build: persisted container `contextId` and `userAgent` must survive process death and restore to the expected session UA before navigation.
2. Verify simultaneous Container A/B UA isolation across open, duplicate, and restored tabs.
3. Verify Proxy A/B runtime behavior and fail-closed behavior.
4. Re-run the focused Dart/native gates after any runtime findings.
5. Validate the existing `build-browser --split-per-abi` release path for supported `android-arm,android-arm64` artifacts and publish each APK independently.
6. Only after the browser milestone is stable, begin AI-1 Browser Tool API.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, or unrelated refactors unless a focused runtime/test result proves the current path insufficient.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `fb09b904e196fd56b8e2ab8436aafae38d7d0337`
**State file updated:** yes.
**Product code changed in this checkpoint:** no.
**CI result:** Quality #29 `33327113039` is green.
**Tests/results:** Dart targeted container suite green; gomobile runtime build green; targeted native UA + Proxy test classes green.
**Current blocker:** only real Android runtime/device validation remains for cold-start restore, A/B UA isolation, and Proxy runtime behavior.
**Exact next step:** execute the real Android cold-start/restored-tab UA validation, then Container A/B isolation. Do not add new architecture before runtime evidence requires it.
