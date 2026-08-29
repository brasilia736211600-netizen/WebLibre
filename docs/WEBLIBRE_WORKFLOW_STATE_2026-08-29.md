# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `7248fa581e8296df73e605d026c8ad4de4e48c4b`

## READ THIS FIRST
This file is the durable execution memory. Do not reconstruct the project from chat history.

## FINAL PRODUCT
Two dependent tracks:
1. Privacy-oriented browser foundation: per-container Proxy + User-Agent, persistence/restore, strict A/B isolation, validation, ABI-split release APKs.
2. Personal AI Browser Agent: owner-only, model/provider independent, operates the real WebLibre browser through an explicit Browser Tool API, with controlled memory and selectable/revocable permissions including Full Access.

The agent has two first-class control surfaces using one Agent Core:
- direct WebLibre in-browser UI;
- authenticated remote control from another phone through a replaceable transport such as Telegram/WhatsApp.
Remote inputs are ordinary natural language plus links/context/constraints; rigid command syntax is not required. Remote authentication never bypasses the permission engine. Task context, grants, memory policy, and audit trail are shared between control surfaces.

Canonical AI spec: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code. This workflow state supersedes older handoff claims only when they conflict with verified source/CI.

### Browser / UA implementation
The current branch already contains the verified implementation pieces for the per-container UA vertical slice:
- `ContainerMetadata.userAgent` persistence/serialization/normalization.
- `AddTabParams.userAgent` source contract and generated Pigeon bindings.
- Normal, multi, and duplicate tab UA creation paths.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` reads the existing per-profile `tab.db` and resolves UA by `contextualIdentity` from persisted container metadata.
- `HistoryDelegateBindingMiddleware.kt` runs before `EngineMiddleware`; on `EngineAction.LinkEngineSessionAction` it resolves the tab/session `contextId` and applies the persisted container UA to `engineSession.settings.userAgentString` before downstream engine linking.
- The same middleware also covers an already-attached session arriving with `TabListAction.AddTabAction`.

No global GeckoRuntime UA, no `_freshSnapshotPending` arrival-order heuristic, no second persistence DB, and no Android Components fork were added.

### Restore status
`UA cold-start/restored-tab integration: IMPLEMENTED IN SOURCE, RUNTIME-UNVERIFIED.`

Verified source facts:
- `RecoverableTab` does not need a new UA field because the restore path retains `contextId` and the native middleware sees the actual engine session.
- `tab.db` is the existing WebLibre Drift database and `container.metadata` is the persisted JSON source for `contextualIdentity` + `userAgent`.
- `HistoryDelegateBindingMiddleware` is registered before `EngineMiddleware.create(...)` in `Core.store`.

## CURRENT GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`
- Current HEAD: `7248fa581e8296df73e605d026c8ad4de4e48c4b`
- PR #3: open, draft, currently mergeable.
- Base: `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c` for PR #3.
- `quality.yml` is intentionally a focused gate: Flutter 3.47.0 bootstrap, targeted container Dart test, then targeted Android unit tests.
- Latest completed quality run `33277537960` checked an older PR merge ref and reached the native step; its native failure was only a workflow command problem (`gradle test --tests ...` rejected `--tests` for the selected lifecycle task). The Dart targeted suite passed 11/11.
- HEAD was then corrected to use `testDebugUnitTest --tests ...`; a new run is expected from PR synchronization. Do not treat the old run as validation of current HEAD.
- Historical native runtime build/Kotlin compilation passed in run `33265003957`.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11 tests passed in the latest completed quality run.
- Native restore parser test: source present; current-head native execution pending after corrected Gradle task selection.
- Full cold-start restore runtime: NOT YET VERIFIED.
- A/B UA isolation: NOT YET VERIFIED.
- Proxy regression/A-B: NOT YET VERIFIED.

## EXACT NEXT EXECUTION
1. Confirm a fresh quality run for HEAD `7248fa5...` and record native test result.
2. If native fails, repair only the first causal compiler/test failure.
3. Once native passes, use the existing full build prerequisite path only for the runtime milestone; do not repeatedly build APKs for narrow changes.
4. Validate cold-start persisted UA restore and concurrent Container A/B UA isolation.
5. Validate Proxy A/B regression and fail-closed behavior required by the existing routing design.
6. Run final targeted Dart/native validation.
7. Build stable release using existing `build-browser` and `--split-per-abi`; publish every supported ABI APK as an independent downloadable artifact. Current scripts target `android-arm,android-arm64`; do not promise x86/x86_64 without a successful build.
8. Start AI-1 Browser Tool API only after the browser milestone is stable.

## PERSONAL AI AGENT ROADMAP
`AI-0 Specification [x] -> AI-1 Browser Tool API -> AI-2 Agent Core -> AI-3 Personal Profile/Memory -> AI-4 Permission Engine -> AI-5 workflows -> AI-6 advanced behavior -> AI-7 model adapters -> AI-8 end-to-end validation`

Permanent requirements: natural-language task understanding, links/context, direct + remote control, owner identity/profile, inspectable/editable/exportable/deletable memory, `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`, task/session/persistent and container/site scopes, revocation, no silent privilege escalation, model/provider independence, and auditability.

## RELEASE APK POLICY
Final release must provide each supported ABI APK as an independently downloadable artifact. Preserve existing `--split-per-abi` behavior. Current release scripts target `android-arm,android-arm64`; publish resulting APKs separately. Do not promise x86/x86_64 unless a build proves support.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent` unless the existing `contextId` + native middleware path proves insufficient. Do not add a new Pigeon API or a second DB without a concrete test failure demonstrating the need. Do not use event-arrival order as request provenance. Do not refactor unrelated code to make CI green.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `7248fa581e8296df73e605d026c8ad4de4e48c4b`
**Files changed in the latest implementation checkpoint:** `.github/workflows/quality.yml` only in the latest CI correction; the UA source implementation remains in the PR and was verified by source inspection.
**Tests/results:** latest completed quality run — Dart targeted tests 11/11 passed; native step failed only because the selected Gradle task rejected `--tests`. Corrected workflow now uses `testDebugUnitTest --tests ...`; fresh run pending.
**Blocker:** runtime/device cold-start validation is not yet available from the current CI path.
**Exact next step:** inspect the fresh quality run for `7248fa5...`; if green, proceed to runtime restore/A-B and Proxy A/B validation, then the split-ABI milestone and AI-1.
