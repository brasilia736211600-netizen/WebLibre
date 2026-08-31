# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD at this state-save:** `44b5524e72dec42d5db58e6d0c90260ff7884dce`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts, and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified checkpoints
- Quality #39 `33329515686`: SUCCESS on UA/container product checkpoint.
- Quality #70 `33335945926`: SUCCESS against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`; AI-1 browser tool tests, targeted container tests, native gomobile build, and targeted native container tests passed. AI-1 execution boundary is CI-VERIFIED.
- Manual Flutter CICD `33337359647`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact `head_sha=26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`; stable APK build and ZIP artifact upload passed.
- Manual Flutter CICD `33341230075`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact `head_sha=3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`; stable APK build and direct validation Release asset creation/upload passed.
- Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`: contains the individually downloadable ARM64 and ARMv7 APK assets. This is RELEASE-ASSET-VERIFIED for that exact build.
- Runtime test of the ARM64 asset from that Release produced the first causal failure recorded below.

## Browser/runtime state
Browser/UA implementation remains SOURCE-VERIFIED and focused CI is green, but real Android runtime proof is now explicitly **FAILED at Scenario 1** for the tested build.

Scenario 1 evidence:
- Before process death: Container A request-observed UA was `Mozilla/5.0 (Linux; Android 14; SM-S928B/DS) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36`.
- After process death/relaunch: Container A and the tab were restored, but request-observed UA became `Mozilla/5.0 (Android 12; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0`.
- Therefore container restoration works at the observed UI level, but persisted per-container UA is not applied to the restored navigation.
- The post-relaunch screen directly showed the restored tab; there was no `Resume last tab` control at that point. Do not treat the earlier home-state `Resume last tab` control as post-relaunch deferred restoration behavior.

The failure is runtime evidence against the current restore/session UA path. Do not proceed to Scenarios 2–6 until the first causal failure is inspected and a focused fix is validated.

## AI-1 state
Six-tool model-independent Browser Tool boundary:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, focused tests, and CI coverage are complete. Do not expand AI-1 unless evidence proves insufficiency.

## Manual APK / Release distribution
The existing build workflow has `workflow_dispatch` for `stable`, `alpha`, and `alphaLegacy` validation builds. Validation builds upload APK artifacts without publishing to Google Play.

The direct GitHub prerelease asset path is implemented and was runtime-tested from validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`.

Future production/stable releases must continue using the existing `v*` path and publish both split-ABI APKs plus the AAB only after Android runtime and release validation are complete.

## CI/build/release evidence gate
For every build/release milestone, do not mark the step complete until this chain is verified:
`intended change -> commit SHA -> workflow revision contains change -> run branch/ref -> run.head_sha == intended SHA -> required job SUCCESS -> required step SUCCESS (not SKIPPED) -> expected artifact/release exists -> expected asset names/URLs/checksum verified`.

A successful older run cannot prove a later workflow change. An artifact ZIP is not equivalent to individual GitHub Release assets.

## Last completed step
The direct GitHub validation Release asset path is RELEASE-ASSET-VERIFIED. The first real Android runtime pass was started and produced a reproducible Scenario 1 failure: Container A restored, but its persisted UA was not applied after process death.

## Current unfinished step
Root-cause source inspection and minimum fix for the Scenario 1 restored-session UA failure. No new architecture should be added unless source/runtime evidence proves the existing restore/session path cannot be corrected minimally.

## Exact next execution
1. Inspect the existing restore/session UA call chain that is supposed to apply the persisted container UA before restored navigation, using the actual code at the current branch HEAD.
2. Identify the first point where `contextId`/container identity is available versus where the `EngineSession` or WebView UA is initialized.
3. Reproduce the failure with the smallest focused test/source reasoning possible; do not run Scenarios 2–6 yet.
4. Implement only the minimum correction if the source path is demonstrably insufficient.
5. Run focused Dart/native/Android-build CI appropriate to the changed path.
6. Produce one new integrated ARM64 validation APK only after the focused checks are green, then repeat Scenario 1.
7. If Scenario 1 passes, resume the consolidated runtime checklist from Scenario 2.

## Resume / anti-amnesia
Canonical resume: `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
Evidence levels: `SOURCE-VERIFIED`, `CI-VERIFIED`, `ANDROID-RUNTIME-VERIFIED`, `ARTIFACT-VERIFIED`, `RELEASE-ASSET-VERIFIED`, `DOCUMENTED`.
At every material milestone update both the master map and workflow state with exact HEAD, CI/build/release identifiers, test evidence, blockers, and one first next step.

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
