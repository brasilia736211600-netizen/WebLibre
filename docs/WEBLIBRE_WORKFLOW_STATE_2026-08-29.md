# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `d91aa8ffd99d087fd8882c0ed3143f6fbc1cd03e`

## READ THIS FIRST
This file is the durable execution memory. GitHub is the source of truth for code/PR/CI. Do not reconstruct the project from chat history.

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
- Actual PR #3 head: `d91aa8ffd99d087fd8882c0ed3143f6fbc1cd03e`.
- PR #3: open, draft, not merged; base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- Current quality run for the actual PR head: `33325379092` / run #22 — **completed failure**.
- Job `dart` completed: bootstrap, Dart targeted container test, and Gradle setup passed; `Run targeted native container tests` failed; failure diagnostics artifact uploaded successfully.
- The artifact exists as `native-test-diagnostics` (artifact id `9736107592`) but the current connector can enumerate it, not read/download its binary payload. Therefore the native causal error is **not yet exposed** and no product-code change is justified.
- `quality.yml` currently runs `gradle --no-daemon --stacktrace testDebugUnitTest` with the two targeted native test classes and failure-only diagnostics capture.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11/11 passed in the latest completed quality run.
- Native targeted tests: RED in run `33325379092`; exact Gradle/compiler/test failure text unavailable through the current GitHub connector.
- Native restore parser test: source present; runtime execution pending.
- Full cold-start restore runtime: NOT VERIFIED.
- Concurrent Container A/B UA isolation: NOT VERIFIED.
- Proxy regression/A-B and fail-closed behavior: NOT VERIFIED.
- Historical native runtime build/Kotlin compilation: passed in run `33265003957`.

## LAST COMPLETED STEP
After interruption, reconciled the durable state against GitHub: verified the actual PR head, current PR metadata, and current CI. The latest native run completed with failure after Dart and Gradle setup passed; its diagnostics artifact was successfully produced but its payload is not readable through the current connector.

## CURRENT UNFINISHED STEP
Obtain the actual native Gradle failure text for PR head `d91aa8ffd99d087fd8882c0ed3143f6fbc1cd03e`. Do not change product code until the concrete compiler/test failure is visible.

## EXACT NEXT EXECUTION
1. Inspect/read the native failure diagnostics for run `33325379092` if the GitHub connector exposes the artifact/log payload.
2. If a concrete native failure is exposed, repair only the first causal Gradle/compiler/test failure and rerun targeted tests.
3. If native is green, validate cold-start persisted UA restore and concurrent Container A/B UA isolation.
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
**HEAD:** `d91aa8ffd99d087fd8882c0ed3143f6fbc1cd03e`
**Files changed in this checkpoint:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Tests/results:** Dart targeted suite 11/11 green; quality run `33325379092` native targeted step failed; diagnostics artifact `native-test-diagnostics` exists but is not readable through the current connector.
**Blocker:** exact native failure text is unavailable; runtime/device restore is also not yet verified.
**Exact next step:** obtain the native failure payload; if available, fix only its first causal failure and rerun. Otherwise do not speculate or modify product code.
