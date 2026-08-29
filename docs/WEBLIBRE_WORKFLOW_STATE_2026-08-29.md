# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `8a788abd449e0fb5dd423a9d24bece602fbbc399`

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
- Current HEAD: `8a788abd449e0fb5dd423a9d24bece602fbbc399`.
- PR #3: open, draft, currently mergeable.
- Base: `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c` for PR #3.
- `quality.yml` is intentionally a focused gate: Flutter 3.47.0 bootstrap, targeted container Dart test, then targeted Android unit tests.
- The latest native quality run reached the native test step after Dart passed, but its failure text was not exposed by the connector. The corrected native task is `testDebugUnitTest --tests ...`.
- A diagnostic follow-up commit `8a788abd...` adds failure-only Gradle report collection as an artifact so the next native failure can be diagnosed without guessing. No product code was changed by this diagnostic commit.
- Historical native runtime build/Kotlin compilation passed in run `33265003957`.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11 tests passed in the latest completed quality run.
- Native restore parser test: source present; current-head native execution result pending.
- Full cold-start restore runtime: NOT YET VERIFIED.
- A/B UA isolation: NOT YET VERIFIED.
- Proxy regression/A-B: NOT YET VERIFIED.

## EXACT NEXT EXECUTION
1. Obtain the fresh quality run for HEAD `8a788abd...` and inspect the native result.
2. If native fails, consume the uploaded diagnostic artifact and repair only the first causal compiler/test failure.
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
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `8a788abd449e0fb5dd423a9d24bece602fbbc399`
**Files changed in the latest checkpoint:** `.github/workflows/quality.yml`, `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Tests/results:** Latest completed Dart targeted suite — 11/11 passed. Latest native quality run reached the native step but the connector did not expose the failure text. A diagnostic artifact collection step is now present for future failure diagnosis.
**Blocker:** native current-head execution result and runtime/device cold-start restoration are not yet verified.
**Exact next step:** inspect the fresh quality run for `8a788abd...`; if native fails, use the uploaded Gradle diagnostics and repair only the first causal error; if green, proceed to restore/A-B, Proxy A/B, split-ABI milestone, then AI-1.
