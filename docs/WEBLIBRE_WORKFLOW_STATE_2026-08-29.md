# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `bfe19a397ab08494244856fec27cd19f42ad062a`

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

## BROWSER STATUS
### Complete
- `ContainerMetadata.userAgent` persistence/serialization/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal, multi, and duplicate tab UA creation paths.
- Existing per-container UA UI.

### Restore slice — IMPLEMENTED, RUNTIME-UNVERIFIED
Android Components SessionStorage does not serialize container UA in `TabSessionState`. Current solution:
- `ContainerUserAgentStore.kt` reads the existing WebLibre Drift `tab.db`, whose `container.metadata` JSON is the persisted source for container metadata.
- `HistoryDelegateBindingMiddleware` looks up by `contextualIdentity` at `LinkEngineSessionAction` and applies `userAgentString` to the session.
- `ContainerUserAgentStoreTest.kt` covers matching UA, cross-container isolation, blank/default, and malformed metadata.
- Verified source: Drift provider opens the same profile `tab.db`; `container.metadata` is mapped through `ContainerMetadataConverter` and contains `contextualIdentity` + `userAgent`.
No new Pigeon recovery field, second DB, global GeckoRuntime UA, or Android Components fork.

## CURRENT GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`
- Current HEAD: `bfe19a397ab08494244856fec27cd19f42ad062a`
- PR #3: open, draft.
- `.github/workflows/quality.yml` is a focused PR gate: Flutter 3.47.0 bootstrap, targeted container test, then one Debug APK build. It intentionally does not run full-project analyzer because the branch contains unrelated legacy warnings/missing assets.
- Prior targeted quality run `33274667912` on `9076f9c...` passed.
- New quality run `33274868548` is **in progress** on `bfe19a397...`; it includes the first actual debug APK build for native/plugin compilation.
- Historical native CI run `33265003957` passed native runtime prerequisites and Kotlin compilation.

## TESTING CHECKPOINT
Dart targeted validation is green. Native restore runtime remains unverified until debug APK build completes and/or device execution is available.

## EXACT NEXT EXECUTION
1. Read result of quality run `33274868548`.
2. If Debug APK build fails: fix only the first causal native/Gradle/Kotlin failure.
3. If it passes: validate cold-start UA restore and A/B container isolation; use any existing automated route available before manual device test.
4. Validate Proxy restore/A-B isolation.
5. Final targeted Dart/native validation.
6. Build stable release through existing `build-browser` with `--split-per-abi`; publish each supported ABI APK separately, not a merged universal APK.
7. Start AI-1 Browser Tool API.

Do not redo completed UA creation/UI work. Do not resurrect `_freshSnapshotPending`. Do not add `RecoverableTab.userAgent` without evidence. Do not add a second DB unless the existing persistence source proves insufficient.

## PERSONAL AI AGENT ROADMAP
`AI-0 Specification [x] -> AI-1 Browser Tool API -> AI-2 Agent Core -> AI-3 Personal Profile/Memory -> AI-4 Permission Engine -> AI-5 workflows -> AI-6 advanced behavior -> AI-7 model adapters -> AI-8 end-to-end validation`

Permanent requirements: natural-language task understanding, links/context, direct + remote control, owner identity/profile, inspectable/editable/exportable/deletable memory, `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`, task/session/persistent and container/site scopes, revocation, no silent privilege escalation, model/provider independence, and auditability.

## RELEASE APK POLICY
Final release must provide each supported ABI APK as an independently downloadable artifact. Preserve existing `--split-per-abi` behavior. Current release scripts target `android-arm,android-arm64`; publish resulting APKs separately. Do not promise x86/x86_64 unless a build proves support.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `bfe19a397ab08494244856fec27cd19f42ad062a`
**Files changed:** `.github/workflows/quality.yml`, `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Tests/results:** targeted container test passed on `33274667912`; `33274868548` is currently validating that test plus Debug APK build.
**Current blocker:** runtime/device verification of restored UA/A-B isolation.
**Exact next step:** inspect `33274868548`; then fix only the first build failure or proceed immediately to restore/A-B and Proxy A/B.
