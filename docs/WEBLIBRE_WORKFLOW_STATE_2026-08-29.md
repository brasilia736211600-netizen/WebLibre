# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`

## READ THIS FIRST
This file is durable execution memory. GitHub is the source of truth for code/PR/CI. Do not reconstruct the project from chat history.

## FINAL PRODUCT
Two dependent tracks:
1. Privacy-oriented browser foundation: per-container Proxy + User-Agent, persistence/restore, strict A/B isolation, validation, ABI-split release APKs.
2. Personal AI Browser Agent: owner-only, model/provider independent, operates the real WebLibre browser through an explicit Browser Tool API, controlled memory, selectable/revocable permissions including Full Access, direct in-browser control plus authenticated remote control from another phone (replaceable Telegram/WhatsApp transport).

Canonical AI spec: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

## CURRENT EXECUTION TRUTH
### Browser / UA
Implemented source pieces verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal, multi, and duplicate tab UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted UA by `contextualIdentity` from the existing profile-scoped `tab.db`.
- `HistoryDelegateBindingMiddleware.kt` is registered before `EngineMiddleware`; it applies the persisted container UA for `LinkEngineSessionAction` and also handles an already-attached session through `TabListAction.AddTabAction`.
- No global GeckoRuntime UA, `_freshSnapshotPending` heuristic, second DB, new recovery Pigeon field, or Android Components fork was added.

### Restore
`UA cold-start/restored-tab integration: IMPLEMENTED IN SOURCE, RUNTIME-UNVERIFIED.`
Restore retains `contextId`; no `RecoverableTab.userAgent` field was added. `tab.db` is the existing WebLibre Drift database and `container.metadata` is the persisted JSON source for `contextualIdentity` + `userAgent`.

## CURRENT GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Actual branch ref HEAD at the start of this execution was `2be3dc78464a97c516cd59541ca4c4578ed9ce75`; after the required CI fix it advanced to `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`.
- PR #3 is open, draft, and not merged; base `main` remains `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- PR metadata may lag the branch ref; branch ref/commit object is the authoritative execution HEAD.
- Quality run #24 `33326192759` for `9cfeed58...` failed because the Flutter host project was now used correctly, but `apps/weblibre/android/app/build.gradle` stopped configuration because the existing combined gomobile runtime AAR was absent.
- Quality run #25 `33326217737` for state commit `2be3dc...` reproduced the same first causal failure. Logs expose the exact error: `Missing combined gomobile runtime AAR: native/go_mobile_runtime/build/weblibre-go.aar` from `apps/weblibre/android/app/build.gradle` line 89.
- The existing release workflow already proves the supported native-runtime preparation: Java 17, Go 1.25.x, NDK from `weblibre.ndkVersion`, pinned `sing-box` and `IPtProxy` sources from `native/go_mobile_runtime/pins.env`, then `melos run build-go-runtime --no-select`.
- The minimal CI-only fix was applied to `.github/workflows/quality.yml`: install Java 17 and Go 1.25.x, install the pinned Android NDK, checkout the pinned native runtime sources (`SING_BOX_TAG=v1.13.12`, `SING_BOX_COMMIT=1086ab2563320e0da0c23b3a491d8dfa0939dff4`, `IPTPROXY_TAG=5.4.2`, `IPTPROXY_COMMIT=3b99b6b1f4d5b51aea97d7213bc36e74ec77c84d`), build the existing gomobile runtime, then run the targeted native tests through the Flutter Android host project.
- CI fix commit: `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1` (`ci: build gomobile runtime before native tests`).
- No product-code change was made in this step.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11/11 passed in runs #24 and #25 before native gating.
- Native targeted tests in runs #24/#25: RED before test execution because the host Gradle project lacked the generated gomobile AAR; this is now addressed in CI preparation.
- Native runtime build/Kotlin compilation: historical runtime build/Kotlin compilation passed in run `33265003957`; the new quality workflow now explicitly builds the runtime before native tests.
- New quality run for `1c8e9732...`: not yet visible immediately after commit creation.
- Native restore parser test: source present; runtime execution pending.
- Full cold-start restore runtime: NOT VERIFIED.
- Concurrent Container A/B UA isolation: NOT VERIFIED.
- Proxy regression/A-B and fail-closed behavior: NOT VERIFIED.

## LAST COMPLETED STEP
Inspected the concrete failure of quality runs #24/#25, confirmed the missing `weblibre-go.aar` prerequisite, and applied the smallest CI-only repair by reproducing the already-proven native-runtime build preparation from the release workflow. Commit: `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`.

## CURRENT UNFINISHED STEP
Verify that the new CI gate builds the existing gomobile runtime and reaches/runs the two targeted native test classes successfully. Do not change product code unless a concrete native compiler/test failure is exposed after the prerequisite is built.

## EXACT NEXT EXECUTION
1. Inspect the PR-triggered `WebLibre Quality` run for HEAD `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`.
2. If the runtime build/native tests fail, inspect the first causal error and repair only that failure.
3. If native tests pass, validate cold-start persisted UA restore and concurrent Container A/B UA isolation.
4. Validate Proxy A/B regression and fail-closed behavior.
5. Run final targeted Dart/native validation.
6. Use existing `build-browser` with `--split-per-abi`; current scripts target `android-arm,android-arm64`; publish each supported ABI APK independently. Do not promise x86/x86_64 without a successful build.
7. Start AI-1 Browser Tool API only after the browser milestone is stable.

## PERSONAL AI AGENT ROADMAP
`AI-0 Specification [x] -> AI-1 Browser Tool API -> AI-2 Agent Core -> AI-3 Personal Profile/Memory -> AI-4 Permission Engine -> AI-5 workflows -> AI-6 advanced behavior -> AI-7 model adapters -> AI-8 end-to-end validation`

Permanent requirements: natural-language task understanding, links/context/constraints, direct + remote control, owner identity/profile, inspectable/editable/exportable/deletable memory, `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`, task/session/persistent and container/site scopes, revocation, no silent privilege escalation, model/provider independence, and auditability. Remote authentication never bypasses the permission engine; both control surfaces share task context, grants, memory policy, and audit trail.

## RELEASE APK POLICY
Final release must provide each supported ABI APK as an independently downloadable artifact. Preserve existing `--split-per-abi` behavior. Current release scripts target `android-arm,android-arm64`; publish resulting APKs separately.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, an event-arrival freshness heuristic, or unrelated refactors unless a focused test proves the current path insufficient.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `1c8e9732fb144f5baf3fb611ef0a6e6ec9c493f1`
**Files changed in this checkpoint:** `.github/workflows/quality.yml`, `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Execution:** diagnosed the missing gomobile AAR from runs #24/#25; applied only the CI prerequisite needed to build the existing runtime before the targeted native tests; saved this durable state.
**Tests/results:** Dart 11/11 green; previous native gate failed before test execution on missing AAR; new CI result pending immediately after commit.
**Blocker:** new native CI run and device/runtime restore remain unverified.
**Exact next step:** inspect the new quality run for `1c8e9732...`; fix only a concrete first failure, otherwise proceed to runtime restore/A-B verification.
