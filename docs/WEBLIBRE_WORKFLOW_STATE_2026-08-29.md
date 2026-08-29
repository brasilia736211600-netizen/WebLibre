# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `f96693775344f17c703cb88d46788f9471fc23eb`

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
- `ContainerUserAgentStore.kt` reads the existing WebLibre per-profile Drift `tab.db`, whose `container.metadata` JSON is the persisted source for container metadata.
- `HistoryDelegateBindingMiddleware` looks up by `contextualIdentity` at `LinkEngineSessionAction` and applies `userAgentString` to the session.
- `ContainerUserAgentStoreTest.kt` covers matching UA, cross-container isolation, blank/default, and malformed metadata.
- Verified source: `ProfileContext.getDatabasePath()` maps `tab.db` to the active profile database directory; Drift's `ContainerData` persists metadata JSON containing `contextualIdentity` + `userAgent`.
No new Pigeon recovery field, second DB, global GeckoRuntime UA, or Android Components fork.

## CURRENT GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`
- Current HEAD: `f96693775344f17c703cb88d46788f9471fc23eb`
- PR #3: open, draft, mergeable.
- `.github/workflows/quality.yml` is a focused PR gate: Flutter 3.47.0 bootstrap, targeted container test, then native plugin unit tests in `packages/flutter_mozilla_components/android` using the runner's `gradle --no-daemon test`. It intentionally does not run full-project analyzer or full APK build.
- Prior targeted container validation run passed: 11 tests.
- Prior native test run failed only because the workflow invoked nonexistent `./gradlew`; this was a workflow error, not a product/compiler result.
- Current quality run `33277147630` is/was for the previous workflow commit; current HEAD `f966937...` has a fresh quality run `33277147630` lineage pending/active after the corrected Gradle invocation. Do not treat the old failure as a failure of current native code.
- Historical native runtime build and Kotlin compilation passed in `33265003957`.

## TESTING CHECKPOINT
- Dart targeted container serialization/metadata test: GREEN (11 tests passed).
- Kotlin/native restore parser test: present but full native test execution on the corrected workflow is the next automated proof.
- Cold-start restore runtime and A/B isolation remain unverified until a real APK/device path is exercised.

## EXACT NEXT EXECUTION
1. Inspect the quality run triggered by HEAD `f966937...`; confirm the native Gradle unit tests actually execute and record result.
2. If native tests fail, fix only the first causal compiler/test error.
3. If they pass, build/validate a debug APK through the existing release prerequisite path (gomobile runtime + assets) only when needed for native runtime proof.
4. Validate cold-start UA restore and A/B isolation; then Proxy restore/A-B regression.
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
**HEAD:** `f96693775344f17c703cb88d46788f9471fc23eb`
**Files changed since prior checkpoint:** `.github/workflows/quality.yml` only in the most recent commit; workflow state is being synchronized by this checkpoint.
**Tests/results:** previous Dart targeted test = 11 passed; previous native job reached native step but failed only because `./gradlew` was not present. Corrected workflow now uses `gradle --no-daemon test`; fresh PR quality run is expected for this HEAD.
**Exact next step:** inspect fresh run for `f966937...`, then proceed to native runtime/restore A-B verification if green.
