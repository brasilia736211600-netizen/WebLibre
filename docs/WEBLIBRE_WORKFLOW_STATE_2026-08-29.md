# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `9cfeed58ec77fac220b292d74848ed8ef54724cc`

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
- Actual branch ref HEAD: `9cfeed58ec77fac220b292d74848ed8ef54724cc` (`ci: run native tests through Flutter Android project`).
- PR #3: open, draft, not merged, base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- The PR metadata endpoint currently reports a stale head SHA (`9c0e30b799b1484afe6f3c9d9e0b74cebf3a80d9`) while the branch ref and commit object both resolve to `9cfeed58ec77fac220b292d74848ed8ef54724cc`; use the branch ref/commit as the actual HEAD.
- Previous quality run for HEAD `d91aa8ffd99d087fd8882c0ed3143f6fbc1cd03e`: `33325379092` / run #22 — completed failure at native compilation.
- Its diagnostics artifact `native-test-diagnostics` (artifact id `9736107592`) was successfully downloaded and inspected.
- First causal native failure: `:compileDebugKotlin` was compiling `packages/flutter_mozilla_components/android` as a standalone Gradle project, so Flutter embedding classes were absent (`Unresolved reference 'io'`, `PlatformViewFactory`, `PlatformView`, `FlutterPlugin`, `ActivityAware`, `readValue`, etc.). This is a CI invocation/classpath problem, not evidence of a product-code defect.
- The targeted native test invocation was therefore changed to run from `apps/weblibre/android` as `:flutter_mozilla_components:testDebugUnitTest`, where the Flutter Android project/plugin loader supplies the plugin's Flutter dependencies. Diagnostics paths were moved accordingly.
- New CI commit: `9cfeed58ec77fac220b292d74848ed8ef54724cc`.
- No CI workflow run for `9cfeed58...` was visible immediately after the commit; the next check is to inspect whether the PR-triggered quality run has started/completed.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11/11 passed in the latest completed quality run.
- Previous native targeted run `33325379092`: RED at `:compileDebugKotlin`; exact first causal errors are now known and recorded above.
- Historical native runtime build/Kotlin compilation: passed in run `33265003957`.
- Native restore parser test: source present; runtime execution pending.
- Full cold-start restore runtime: NOT VERIFIED.
- Concurrent Container A/B UA isolation: NOT VERIFIED.
- Proxy regression/A-B and fail-closed behavior: NOT VERIFIED.

## LAST COMPLETED STEP
After reconciling the durable state with the actual GitHub branch, commits, PR and CI, inspected the previously inaccessible native diagnostics and identified the first causal failure. The minimal fix was applied to CI only: execute the plugin's native unit tests through the Flutter Android host project instead of the standalone plugin Gradle project. Commit: `9cfeed58ec77fac220b292d74848ed8ef54724cc`.

## CURRENT UNFINISHED STEP
Verify the new CI invocation actually compiles/runs the two targeted native test classes. Do not change product code unless the new run exposes a concrete product/test failure.

## EXACT NEXT EXECUTION
1. Inspect the PR-triggered `WebLibre Quality` run for HEAD `9cfeed58ec77fac220b292d74848ed8ef54724cc`.
2. If native tests fail, inspect the new diagnostics and repair only the first causal failure.
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
**HEAD:** `9cfeed58ec77fac220b292d74848ed8ef54724cc`
**Files changed in this checkpoint:** `.github/workflows/quality.yml`, `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Execution:** inspected artifact `native-test-diagnostics` from run `33325379092`; identified standalone Gradle Flutter-classpath failure; changed only CI invocation to run the plugin unit tests through `apps/weblibre/android`; saved this state.
**Tests/results:** Dart targeted suite 11/11 green; previous native run failed at `:compileDebugKotlin`; new CI result pending/not yet visible immediately after commit.
**Blocker:** new native CI result and runtime/device cold-start restoration remain unverified.
**Exact next step:** inspect the new PR quality run for `9cfeed58...`; fix only a concrete first failure if one appears, otherwise proceed to runtime restore/A-B verification.
