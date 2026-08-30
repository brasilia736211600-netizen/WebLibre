# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `45f98d857d3f4a976367d7ff0e57266e9de9d969`

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
- Current HEAD: `45f98d857d3f4a976367d7ff0e57266e9de9d969` (`ci: capture native Gradle failure output`).
- PR #3: open, draft, mergeable; head branch `weblibre-ua-mainline-v3`; PR metadata currently identifies head SHA `45f98d857d3f4a976367d7ff0e57266e9de9d969`; base `main` at `c82e189b1b78dcc5ded582305c63bd1222eec19c`.
- PR #3 currently contains 74 commits and 28 changed files; it is not merged.
- `quality.yml` is a focused gate: Flutter 3.47.0 bootstrap, targeted container Dart test, then targeted Android unit tests.
- The previous native quality run for this head failed at the native test step. Its diagnostics artifact contained only `find: 'build/test-results': No such file or directory` and `find: 'build/reports/tests': No such file or directory`; it did not expose the actual Gradle failure output.
- Commit `45f98d857d...` changed `quality.yml` to capture the native Gradle stdout/stderr into `native-gradle-output.txt`, then upload that file plus failure markers/report files on failure.
- The failed native job was re-run from GitHub as the exact next action; the current workflow run `33279398301` is now `queued`.
- Historical native runtime build/Kotlin compilation passed in run `33265003957`.

## TESTING CHECKPOINT
- Dart targeted container metadata test: GREEN — 11 tests passed in the latest completed quality run.
- Native targeted tests: current result pending; rerun is queued after the diagnostic-capture fix.
- Native restore parser test: source present; runtime execution pending.
- Full cold-start restore runtime: NOT YET VERIFIED.
- A/B UA isolation: NOT YET VERIFIED.
- Proxy regression/A-B: NOT YET VERIFIED.

## LAST COMPLETED STEP
The last completed engineering step was to establish actionable native CI diagnostics without changing product code: the native Gradle command now captures its full output and the failure path uploads it as an artifact. This was committed as `45f98d857d3f4a976367d7ff0e57266e9de9d969`.

## CURRENT UNFINISHED STEP
The current first unfinished step is **obtain and inspect the rerun result of the native targeted tests** for HEAD `45f98d857d3f4a976367d7ff0e57266e9de9d969`. Do not change product code until the actual native failure is visible.

## EXACT NEXT EXECUTION
1. Inspect the queued/running/completed quality run `33279398301` for HEAD `45f98d857d3f4a976367d7ff0e57266e9de9d969`.
2. If native fails, download the new `native-test-diagnostics` artifact and repair only the first causal Gradle/compiler/test failure.
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
**HEAD:** `45f98d857d3f4a976367d7ff0e57266e9de9d969`
**Files changed in this checkpoint:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Execution performed:** re-ran the failed native CI job after verifying that the earlier diagnostic artifact was insufficient; the rerun is currently queued.
**Evidence:** HEAD/PR verified from GitHub; PR #3 is open/draft/mergeable; Dart target is 11/11 green; previous native run failed at the native test step; diagnostic artifact from that run only contained missing-build-directory messages; CI HEAD commit now captures full Gradle output.
**Blocker:** current native test result is not yet available, so product code changes would be speculative.
**Exact next step:** inspect workflow run `33279398301`; if it fails, consume the new diagnostic artifact and fix only the first causal native failure; if it passes, move to actual cold-start UA restore and A/B runtime verification, then Proxy verification.
