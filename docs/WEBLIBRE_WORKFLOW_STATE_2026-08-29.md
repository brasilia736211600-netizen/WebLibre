# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `3ca43b6182489ad574045de12139118aaafbb6e6`

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
The current branch contains the implemented per-container UA vertical-slice pieces:
- `ContainerMetadata.userAgent` persistence/serialization/normalization.
- `AddTabParams.userAgent` source contract and generated Pigeon bindings.
- Normal, multi, and duplicate tab UA creation propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted UA by `contextualIdentity` from the existing profile-scoped `tab.db`.
- `HistoryDelegateBindingMiddleware.kt` is registered before `EngineMiddleware`; for `LinkEngineSessionAction` it resolves `contextId` and applies the persisted container UA to `engineSession.settings.userAgentString` before downstream engine linking, and it also handles an already-attached session arriving through `TabListAction.AddTabAction`.
- No global GeckoRuntime UA, no `_freshSnapshotPending` heuristic, no second persistence DB, and no Android Components fork were added.

### Restore status
`UA cold-start/restored-tab integration: IMPLEMENTED IN SOURCE, RUNTIME-UNVERIFIED.`

Verified source facts:
- Restore retains `contextId`; no new `RecoverableTab.userAgent` field was added.
- `tab.db` is the existing WebLibre Drift database and `container.metadata` is the persisted JSON source for `contextualIdentity` + `userAgent`.
- `HistoryDelegateBindingMiddleware` is registered before `EngineMiddleware.create(...)` in `Core.store`.

## CURRENT GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current HEAD: `3ca43b6182489ad574045de12139118aaafbb6e6` (`docs: synchronize durable workflow checkpoint`).
- PR #3: open, draft, mergeable; head branch `weblibre-ua-mainline-v3`; base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- PR #3 is not merged.
- `quality.yml` is a focused gate: Flutter 3.47.0 bootstrap, targeted container Dart test, then targeted Android unit tests.
- The current quality run for the actual branch HEAD is `33325236868` and is `in_progress`; Dart targeted tests and Gradle setup have passed, and the targeted native test step is currently running.
- The earlier native failure is retained as historical evidence only; its diagnostic artifact did not expose the actual Gradle failure. The current workflow contains failure-only diagnostic capture.
- Historical native runtime build/Kotlin compilation passed in run `33265003957`.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11 tests passed in the latest completed quality run.
- Native targeted tests: current result pending in run `33325236868`.
- Native restore parser test: source present; runtime execution pending.
- Full cold-start restore runtime: NOT YET VERIFIED.
- A/B UA isolation: NOT YET VERIFIED.
- Proxy regression/A-B: NOT YET VERIFIED.

## LAST COMPLETED STEP
Reconciled the durable state against GitHub after interruption: the branch HEAD is `3ca43b6182489ad574045de12139118aaafbb6e6`, and the active quality run is `33325236868`. No product-code changes were made during this reconciliation.

## CURRENT UNFINISHED STEP
Obtain and inspect the native targeted-test result for the actual branch HEAD. Do not change product code unless a concrete native compiler/test failure is exposed.

## EXACT NEXT EXECUTION
1. Inspect quality run `33325236868` for completion and native test result.
2. If native fails, consume its failure diagnostics and repair only the first causal Gradle/compiler/test failure.
3. If native passes, validate cold-start persisted UA restore and concurrent Container A/B UA isolation.
4. Validate Proxy A/B regression and fail-closed behavior required by the existing routing design.
5. Run final targeted Dart/native validation.
6. Use the existing release path with `build-browser` and `--split-per-abi`; current scripts target `android-arm,android-arm64`. Do not promise x86/x86_64 without a successful build.
7. Start AI-1 Browser Tool API only after the browser milestone is stable.

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
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `3ca43b6182489ad574045de12139118aaafbb6e6`
**Files changed in this checkpoint:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Tests/results:** Latest completed Dart targeted suite — 11/11 passed. Current branch quality run `33325236868` is in progress; Dart and Gradle setup passed, native targeted tests are running.
**Blocker:** native test result and runtime/device cold-start restoration are not yet verified.
**Exact next step:** inspect `33325236868`; if native fails, consume diagnostics and fix only the first causal failure; if green, proceed to restore/A-B, Proxy A/B, split-ABI milestone, then AI-1.
