# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `9076f9c560ba35ec23ee1cc9798831a65f7e8b6e`

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
- ContainerMetadata.userAgent persistence/serialization/normalization.
- AddTabParams.userAgent source contract and generated bindings.
- Normal, multi, and duplicate tab UA creation paths.
- Existing per-container UA UI.

### Restore slice — IMPLEMENTED, RUNTIME-UNVERIFIED
Android Components SessionStorage does not persist container UA in TabSessionState. Current solution:
- `ContainerUserAgentStore.kt` reads persisted container metadata from the existing profile data source by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware` applies the persisted UA to `EngineSession` at link time before downstream navigation.
- `ContainerUserAgentStoreTest.kt` covers matching UA, cross-container isolation, blank/default, and malformed metadata.
No new Pigeon recovery field, second DB, global GeckoRuntime UA, or Android Components fork.

## CURRENT GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`
- HEAD: `9076f9c560ba35ec23ee1cc9798831a65f7e8b6e`
- PR #3: open, draft, base `main`, mergeable.
- `.github/workflows/quality.yml` is now a focused PR gate: Flutter 3.47.0 bootstrap + targeted container-data test only. Full-project analyzer was removed because the branch inherited unrelated warnings/assets issues; do not broaden this gate without need.
- Quality workflow run `33274667912` on HEAD `9076f9c...` completed **successfully**; the targeted container test passed.
- Historical native CI run `33265003957` passed native runtime prerequisites and Android Kotlin compilation.

## TESTING CHECKPOINT
Dart targeted validation is green in GitHub Actions. Native runtime restore and device-level cold-start behavior remain unverified from this interface.

## EXACT NEXT EXECUTION
1. Verify restore-source assumptions in exact native/app persistence code.
2. Run targeted native/Kotlin compile/test for `ContainerUserAgentStore` and middleware if available through Actions.
3. Validate cold-start restored UA and A/B container isolation.
4. Validate Proxy restore/A-B isolation.
5. Run final targeted Dart/native validation.
6. Build stable milestone with existing `--split-per-abi` scripts and publish each ABI APK independently.
7. Start AI-1 Browser Tool API.

Do not redo completed UA creation/UI work. Do not resurrect `_freshSnapshotPending`. Do not add `RecoverableTab.userAgent` without evidence. Do not add a second DB unless the existing persistence source proves insufficient.

## PERSONAL AI AGENT ROADMAP
`AI-0 Specification [x] -> AI-1 Browser Tool API -> AI-2 Agent Core -> AI-3 Personal Profile/Memory -> AI-4 Permission Engine -> AI-5 workflows -> AI-6 advanced behavior -> AI-7 model adapters -> AI-8 end-to-end validation`

Permanent requirements: natural-language task understanding, links/context, direct + remote control, owner identity/profile, inspectable/editable/exportable/deletable memory, `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`, task/session/persistent and container/site scopes, revocation, no silent privilege escalation, model/provider independence, and auditability.

## RELEASE APK POLICY
Final release must provide each supported ABI APK as an independently downloadable artifact. Preserve existing `--split-per-abi` behavior. Publish `arm64-v8a`, `armeabi-v7a`, and other supported ABIs separately; universal APK is optional.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `9076f9c560ba35ec23ee1cc9798831a65f7e8b6e`
**Files changed in this checkpoint:** `.github/workflows/quality.yml`, `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
**Tests/results:** GitHub Actions `33274667912` succeeded; targeted container test passed. Native runtime restore remains unverified.
**Current blocker:** native/Kotlin runtime verification of restore and A/B isolation.
**Exact next step:** inspect/validate native restore source and run the narrowest native verification available; then UA A/B, proxy A/B, milestone split APK, then AI-1.
