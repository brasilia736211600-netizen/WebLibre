# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD:** `ef9a08005b1c9ea4c15814b5c9f8aef85a90378c`

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
- Current branch HEAD: `ef9a08005b1c9ea4c15814b5c9f8aef85a90378c` (`docs: add durable master project map`).
- Parent product/state checkpoint: `533dc9a714eaa6d2dfb615f35787f896e76ddd40`.
- PR #3: open, draft, not merged; base `main`.
- Latest verified Quality run: #29 `33327113039` for HEAD `fb09b904...` — SUCCESS.
- Quality #29 passed Dart targeted tests, Android NDK setup, pinned native source checkout, gomobile runtime build, Gradle setup, and targeted native `ContainerUserAgentStoreTest` + `ContainerProxyFeatureTest`.
- Previous Quality #24/#25 failed before native tests because `weblibre-go.aar` was missing; the minimal CI-only prerequisite repair was completed in `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1` and validated by #29.
- The map commit `ef9a080...` is documentation-only; it is not a product-code milestone and does not require another product test.

## LAST COMPLETED STEP
Closed the CI/AAR blocker with Quality #29 green, then created the durable master project map so the complete roadmap and dependency order survive chat/agent changes.

## CURRENT UNFINISHED STEP
Real Android runtime/device validation remains: cold-start/restored-tab UA persistence, simultaneous Container A/B UA isolation, and Proxy A/B/fail-closed runtime behavior.

## EXACT NEXT EXECUTION
1. Perform real Android cold-start/restored-tab UA validation using the current build: persisted `contextId` and `userAgent` must survive process death and restore to the expected session UA before navigation.
2. Verify simultaneous Container A/B UA isolation across open, duplicate, and restored tabs.
3. Verify Proxy A/B runtime behavior and fail-closed behavior.
4. Re-run focused Dart/native gates after any runtime findings.
5. Validate existing `build-browser --split-per-abi` release path for supported `android-arm,android-arm64` artifacts and publish each APK independently.
6. Only after the browser milestone is stable, begin AI-1 Browser Tool API.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, or unrelated refactors unless a focused runtime/test result proves the current path insufficient.

## MASTER PROJECT MAP
`docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` is the durable high-level roadmap. Update it on every material milestone; keep this file as the short execution truth.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `ef9a08005b1c9ea4c15814b5c9f8aef85a90378c`
**Product code changed in this checkpoint:** no.
**CI result:** Quality #29 `33327113039` green.
**Current blocker:** real Android runtime/device validation.
**Exact next step:** cold-start/restored-tab UA validation, then Container A/B isolation. Do not add architecture before runtime evidence requires it.
