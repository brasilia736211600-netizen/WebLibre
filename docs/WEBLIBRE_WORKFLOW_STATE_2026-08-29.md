# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD at this state-save:** `8c2c513cc24454716437f1a2669ecbe05e6ee662`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts, and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified checkpoints
- Quality #39 `33329515686`: SUCCESS on UA/container product checkpoint.
- Quality #70 `33335945926`: SUCCESS against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`; AI-1 browser tool tests, targeted container tests, native gomobile build, and targeted native container tests passed. AI-1 execution boundary is CI-VERIFIED.
- Manual Flutter CICD `33337359647`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact `head_sha=26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`; stable APK build and ZIP artifact upload passed.
- Manual Flutter CICD `33341230075`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact `head_sha=3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`; stable APK build and direct validation Release asset creation/upload passed.
- Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`: contains the individually downloadable ARM64 and ARMv7 APK assets. This is RELEASE-ASSET-VERIFIED for that exact build.
- Runtime test of the ARM64 asset from that Release produced the first causal failure recorded below.
- Current branch HEAD was re-verified before source inspection: `5c7f81023792b51d9185f6c572f1f361bbbf9a01`. The later commits in this milestone are source-diagnostic and documentation state saves.

## Browser/runtime state
Browser/UA implementation is SOURCE-VERIFIED for normal/pre-navigation tab creation and focused CI is green, but real Android runtime proof is explicitly **FAILED at Scenario 1** for the tested build.

Scenario 1 evidence:
- Before process death: Container A request-observed UA was `Mozilla/5.0 (Linux; Android 14; SM-S928B/DS) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36`.
- After process death/relaunch: Container A and the tab were restored, but request-observed UA became `Mozilla/5.0 (Android 12; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0`.
- Therefore container/tab restoration works at the observed UI level, but persisted per-container UA is not applied to the restored navigation.
- The post-relaunch screen directly showed the restored tab; there was no `Resume last tab` control at that point. Do not treat the earlier home-state `Resume last tab` control as post-relaunch deferred restoration behavior.

The failure is runtime evidence against the effectiveness of the current restore/session UA path. Do not proceed to Scenarios 2–6 until the first causal failure is isolated and a focused fix is validated.

## Root-cause source inspection — refined boundary
The actual cold-start path was inspected at the branch HEAD and is recorded in `docs/WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md`.

The automatic restore path is:
`GlobalComponents.restoreBrowserState -> sessionStorage.restore -> RecoverableBrowserState -> tabsUseCases.restore -> RestoreCompleteAction`.

Normal tab creation is different: `GeckoTabsApiImpl.addTab` creates an `EngineSession` and explicitly sets `session.settings.userAgentString = userAgent` before the tab is dispatched/loaded.

The repository already contains `HistoryDelegateBindingMiddleware` and `ContainerUserAgentStore`. The middleware is installed before `EngineMiddleware` and, on `EngineAction.LinkEngineSessionAction`, attempts to read the restored tab's `contextId` from the store, read the existing per-profile `tab.db`, and set `engineSession.settings.userAgentString` before downstream linking.

The middleware/store were introduced by source commits `435c1e8bad653213bfb44e63235ac86741f88db` and `64e196c6213abddde0a4446b1fc876bb142a6edf`. The runtime-tested build contains these changes, yet Scenario 1 still failed. Therefore the remaining blocker is **inside the effectiveness/timing/data boundary of this existing hook**, not proven absence of the hook.

Current unresolved runtime branches:
1. restored `LinkEngineSessionAction` does not reach the middleware as expected;
2. the middleware sees a missing/wrong `contextId`;
3. `ContainerUserAgentStore.get(...)` cannot read `tab.db` at the startup point;
4. the UA assignment occurs too late to affect the restored first navigation;
5. the observed request comes from a different EngineSession than the one bound by the middleware.

No one of these is yet claimed as the final root cause.

## Current diagnostic change
Two low-noise debug-level diagnostic additions were made:
- `HistoryDelegateBindingMiddleware.kt` now records bind entry, tab/context/profile identity, lookup result, assignment timing, and effective setting result.
- `ContainerUserAgentStore.kt` now records blank-context, missing-database, hit, miss, and SQLite-exception branches.

These changes are diagnostic only. They do not introduce a second database, global UA, `RecoverableTab.userAgent`, new Pigeon restore contract, or Android Components fork.

Source commits for the diagnostic code:
- `6aa1cd4f519951468dbb192894489160d2635dfb` — instrument session-link boundary.
- `2e3534c28787ab6bdaf00585e48e6384113bea77` — instrument container UA lookup boundary.

## User observations captured for later product work
- The browser feels relatively heavy. This is currently an observed UX/performance issue, not yet a measured regression or a reason to remove features.
- Previously visited pages should not be unnecessarily reloaded as if they were first visits. The intended behavior is to preserve normal cache/session semantics and avoid avoidable restore-time reloads. Root cause is not yet established.
- Current UA UX is too primitive: raw UA input does not provide coherent OS/browser/version presets or a professional profile-oriented editor.
- Desired future direction is a customizable, coherent browser identity/profile system inspired by current profile/anti-detect browsers, while preserving technical consistency with the underlying Gecko/Android engine.
- A detailed research/requirements document exists at `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`.
- Benchmarked current GoLogin, Multilogin, AdsPower, and Kameleo documentation. The common pattern is profile-level coherent identity management: OS/browser/version, display metrics, locale/timezone, proxy/network, fonts/media devices, WebRTC, Canvas/WebGL/AudioContext and related navigator/hardware signals, with consistency constraints rather than arbitrary UA-string editing.
- These are product requirements/research observations only. Do not implement the full feature set yet and do not infer that all fingerprint surfaces are technically available in WebLibre.

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
The direct GitHub validation Release asset path is RELEASE-ASSET-VERIFIED. The first Android runtime pass produced a reproducible Scenario 1 failure. Source inspection then verified the existing restore-binding implementation and narrowed the blocker to its runtime effectiveness/timing/data boundary. A focused diagnostic was added to distinguish those branches without changing architecture.

## Current unfinished step
Run focused CI/native checks for the diagnostic restore-boundary change, then create one diagnostic ARM64 validation APK and inspect the restore-binding logs to identify the exact runtime failure branch. Only then implement the minimum functional correction indicated by evidence.

## Exact next execution
1. Verify the diagnostic commits are present on the intended branch/HEAD and that no relevant CI run exists yet for that exact HEAD.
2. Run the focused Quality/native checks for the changed middleware/store path.
3. If focused checks are green, run one integrated ARM64 validation build containing the diagnostic instrumentation.
4. On the device, reproduce only Scenario 1 and capture the restore-binding log evidence; do not run Scenarios 2–6.
5. Identify the exact failing branch and implement only the minimum correction.
6. Re-run focused CI, produce one corrected integrated ARM64 validation APK, and repeat Scenario 1.
7. If Scenario 1 passes, resume the consolidated runtime checklist from Scenario 2.
8. Only after the browser foundation runtime milestone is closed, measure cold start, memory, unnecessary reloads, cache/session behavior, and APK size before removing any features.
9. Then design the smallest coherent UA/profile editor from `WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`, implementing only engine-supported controls.

## Resume / anti-amnesia
Canonical resume: `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
Canonical forensic record: `docs/WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md`.
Evidence levels: `SOURCE-VERIFIED`, `CI-VERIFIED`, `ANDROID-RUNTIME-VERIFIED`, `ARTIFACT-VERIFIED`, `RELEASE-ASSET-VERIFIED`, `DOCUMENTED`.
At every material milestone update both Master Map and Workflow State with exact HEAD, CI/build/release identifiers, test evidence, blockers, and one first next step.

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
