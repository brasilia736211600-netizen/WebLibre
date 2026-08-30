# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD before this state save:** `4d256eaa867583ad3ca60563a442bad2520c0275`

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

### Test surface discovered during parallel inspection
- Dart `apps/weblibre/test/features/geckoview/features/tabs/data/models/` currently contains the focused `container_data_test.dart`; no dedicated cold-start restore test was found there.
- Native feature tests include `ContainerUserAgentStoreTest.kt` and the extensive `ContainerProxyFeatureTest.kt` under `packages/flutter_mozilla_components/android/src/test/kotlin/eu/weblibre/flutter_mozilla_components/feature/`.
- `ContainerUserAgentStoreTest.kt` has four focused parser/normalization cases: matching container, different container, blank UA, malformed metadata.
- A unit-test-only addition cannot prove Android process-death/cold-start behavior, so no artificial restore test was added at this checkpoint.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Actual execution HEAD before this state save: `4d256eaa867583ad3ca60563a442bad2520c0275` (`docs: refresh durable workflow state after CI progression`).
- PR #3: open, draft, not merged; base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- PR metadata may lag the branch ref; branch ref/commit object is authoritative.
- Quality #24 `33326192759`: failed because host Gradle was correctly selected but `weblibre-go.aar` was missing.
- Quality #25 `33326217737`: reproduced the same missing-AAR failure.
- CI-only fix `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1` added the existing release-workflow runtime prerequisites: Java 17, Go 1.25.x, pinned Android NDK, pinned `sing-box`/`IPtProxy` sources, and existing `melos run build-go-runtime --no-select` before native tests.
- Quality #28 `33326499423` for execution HEAD `4d256eaa...` completed **SUCCESS**. The same job confirms successful Flutter setup, workspace bootstrap, Dart tests, NDK install, pinned native source checkout, gomobile runtime build, Gradle setup, and targeted native test execution.
- Quality #28 job `99297453045`: targeted native tests completed successfully; diagnostics/upload were skipped because the job was green.
- The corrected CI gate therefore reached actual native test execution and passed; the previous CI infrastructure blockers are closed.

## TESTING CHECKPOINT
- Dart targeted container metadata suite: **11/11 GREEN**.
- Native `ContainerUserAgentStoreTest`: **GREEN** in Quality #28.
- Native `ContainerProxyFeatureTest`: **GREEN** in Quality #28.
- Native gomobile runtime build: **GREEN** in Quality #28.
- Corrected Flutter-host Gradle invocation: **GREEN** in Quality #28.
- Cold-start persisted UA restore: **NOT VERIFIED** on a real Android process lifecycle/device.
- Concurrent Container A/B UA isolation: **NOT VERIFIED** at runtime.
- Proxy A/B runtime regression/fail-closed: **NOT VERIFIED** at runtime; native unit coverage is green.

## LAST COMPLETED STEP
Completed the corrected end-to-end CI gate through actual native unit-test execution. Quality #28 `33326499423` passed, including the existing gomobile runtime build and both targeted native container test classes. No product-code changes were needed.

## CURRENT UNFINISHED STEP
Runtime/device validation of the browser behavior remains. The first required runtime check is cold-start/restored-tab UA persistence, followed by simultaneous Container A/B UA isolation.

## EXACT NEXT EXECUTION
1. Run/perform a real Android cold-start restore validation: persisted container UA + restored tab retain the correct `contextId` and resolve the expected UA.
2. Verify simultaneous Container A/B UA isolation across open, duplicate, and restored tabs.
3. Verify Proxy A/B behavior and fail-closed behavior at runtime.
4. Re-run the focused Dart/native gates after runtime findings.
5. Validate the existing `build-browser --split-per-abi` release path for supported `android-arm,android-arm64` artifacts and publish each APK independently.
6. Only after the browser milestone is stable, begin AI-1 Browser Tool API.

## PERSONAL AI AGENT ROADMAP
`AI-0 Specification [x] -> AI-1 Browser Tool API -> AI-2 Agent Core -> AI-3 Personal Profile/Memory -> AI-4 Permission Engine -> AI-5 workflows -> AI-6 advanced behavior -> AI-7 model adapters -> AI-8 end-to-end validation`

Permanent requirements: natural-language task understanding, links/context/constraints, direct + remote control, owner identity/profile, inspectable/editable/exportable/deletable memory, `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`, task/session/persistent and container/site scopes, revocation, no silent privilege escalation, model/provider independence, and auditability. Remote authentication never bypasses the permission engine; both control surfaces share task context, grants, memory policy, and audit trail.

## RELEASE APK POLICY
Final release must provide each supported ABI APK as an independently downloadable artifact. Preserve existing `--split-per-abi` behavior. Current release scripts target `android-arm,android-arm64`; publish resulting APKs separately.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, or unrelated refactors unless a focused test proves the current path insufficient.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD recorded before state save:** `4d256eaa867583ad3ca60563a442bad2520c0275`
**State file updated:** yes.
**Product code changed in this checkpoint:** no.
**CI changes:** already completed in prior CI-only commits; Quality #28 now green.
**Tests/results:** Dart targeted 11/11 green; gomobile runtime green; targeted native UA + Proxy test classes green in Quality #28.
**Current blocker:** only real Android runtime/device validation remains for cold-start restore and A/B isolation, plus final Proxy runtime validation.
**Exact next step:** execute the runtime cold-start/restored-tab UA test, then Container A/B isolation; do not add new architecture before those runtime results require it.
