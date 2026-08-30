# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD:** `2dfbe49165ba392cfc00cf4c7c921ff3864a6ae7`

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

## GIT / PR / CI
- Branch ref HEAD: `2dfbe49165ba392cfc00cf4c7c921ff3864a6ae7` (`docs: save gomobile CI prerequisite state`).
- PR #3: open, draft, not merged; base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- PR metadata may lag branch ref; branch ref is authoritative.
- Quality #24 `33326192759`: failed because host Gradle was correctly selected but `weblibre-go.aar` was missing.
- Quality #25 `33326217737`: reproduced the same missing-AAR failure.
- The minimal CI-only fix was committed as `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`: Java 17 + Go 1.25.x + pinned NDK + pinned native runtime sources + existing `melos run build-go-runtime --no-select` before native tests.
- Quality #26 `33326394522` is associated with `1c8e9732...` and is currently still running.
- Quality #27 `33326406757` is associated with current state HEAD `2dfbe491...` and is also currently running.
- Latest observed job state: the `dart` job in #26 had passed bootstrap and was in targeted container tests; live log retrieval during execution returned a transient GitHub blob 404, so no new failure was inferred. #27 was confirmed `in_progress` but had not yet exposed a result at this checkpoint.

## TESTING CHECKPOINT
- Dart targeted container metadata suite: 11/11 GREEN in completed runs.
- Native targeted tests: not yet executed to completion under the corrected runtime-build prerequisite.
- Native runtime build/Kotlin compilation: historical build/Kotlin compilation passed in run `33265003957`; corrected CI now builds gomobile runtime explicitly before native tests.
- Cold-start persisted UA restore: NOT VERIFIED.
- Concurrent Container A/B UA isolation: NOT VERIFIED.
- Proxy A/B regression/fail-closed: NOT VERIFIED.

## LAST COMPLETED STEP
Diagnosed the concrete missing `weblibre-go.aar` prerequisite from quality #24/#25 and reproduced the already-supported release preparation in `quality.yml` without changing product code. Commit `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`.

## CURRENT UNFINISHED STEP
Allow the corrected CI path to complete: build the existing gomobile runtime, then reach and execute the two targeted native tests.

## EXACT NEXT EXECUTION
1. Inspect quality runs #26 and #27 until a definitive native/runtime result is available.
2. On failure, inspect the first causal error only and repair only that issue.
3. On native green, perform cold-start persisted-UA restore and A/B UA isolation validation.
4. Validate Proxy A/B and fail-closed behavior.
5. Run final targeted Dart/native checks.
6. Preserve existing split-ABI release behavior (`android-arm,android-arm64`) and publish each resulting APK independently.
7. Start AI-1 Browser Tool API only after the browser milestone is stable.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, or unrelated refactors unless a focused test proves the current path insufficient.

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Branch HEAD:** `2dfbe49165ba392cfc00cf4c7c921ff3864a6ae7`
**State file updated:** yes.
**Product code changed in this checkpoint:** no.
**CI fix in scope:** yes, CI only.
**Current blocker:** corrected native CI gate has not yet produced a definitive runtime/native-test result.
**Exact next step:** inspect #26/#27; fix only the first concrete failure, otherwise proceed to runtime restore/A-B verification.
