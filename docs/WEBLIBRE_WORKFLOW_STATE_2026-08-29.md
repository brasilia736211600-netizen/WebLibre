# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Last synchronized HEAD before this state commit:** `4ac7001403306756383b8cf388ba8614e35cc7c9`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence. The GitHub branch ref is the final authority for the current HEAD because documentation commits necessarily advance the ref after they are written.

## Verified current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Branch HEAD verified immediately before this state update: `4ac7001403306756383b8cf388ba8614e35cc7c9` (`docs: reconcile master map checkpoint`). This documentation commit advances the branch ref again; the post-commit branch SHA must be read from GitHub when this state is next resumed.
- The current Quality workflow contains AI-1 registry/executor tests and targeted container/native tests.
- No verified current-head Quality run or commit status checks are available for the `4ac700...` checkpoint.
- The GitHub connector exposes no workflow-dispatch action in this session.

## Browser / Android runtime
Scenario 1 remains **FAIL**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor, source mappings and focused tests are SOURCE-VERIFIED. The current `browser_tool_executor.dart` has an explicit terminal fallback return after dispatch; do not reapply the historical missing-return patch without new evidence. Current Quality CI proof remains pending.

## Privacy / personal-product hardening
The privacy/account source boundary remains SOURCE-VERIFIED with Flutter build verification on exact historical checkpoint `eea4b40...`. Documentation/source commits after that checkpoint do not extend build evidence to newer HEADs.

The automatic release-startup/background headless feed refresh path has been removed at source level: production `BackgroundFetch.configure`, the headless task registration, the dedicated headless entrypoint, and the direct `background_fetch` app dependency are removed. Manual foreground feed refresh remains intentionally retained.

**Dependency/lockfile verification completed:** the current `apps/weblibre/pubspec.yaml` contains no direct `background_fetch` dependency, and `apps/weblibre/pubspec.lock` is not tracked/present on `weblibre-ua-mainline-v3`. Therefore there is no repository lockfile entry to edit; no manual generated-lockfile mutation was made. A future dependency resolution/build remains the proper runtime-level confirmation.

Still pending: hidden account/sync initializer reachability audit, dead-source cleanup after reachability proof, outbound endpoint/background-service audit, Android permission/cleartext minimization review, local privacy/data-flow screen, current-head CI evidence, and Android UA Scenario 1 root-cause fix/revalidation.

## UA source checkpoint
The current UA restore path captures `GlobalComponents.components?.profileApplicationContext` at `HistoryDelegateBindingMiddleware` construction instead of looking it up again for every restore action. This is a SOURCE-VERIFIED lifecycle stabilization only; the Android Scenario 1 result is not promoted until fresh runtime evidence confirms the behavior.

## Device-build policy
Physical Android installation/testing is intentionally deferred until the highest-value source/CI/review work is complete. Do **not** generate/install an APK merely to re-run an already-unverified source question. The intended device phase is one consolidated validation pass near release readiness.

## Last completed step
**Verified the background-fetch dependency state on the active branch: direct dependency removed and no tracked `pubspec.lock` exists. No generated lockfile was hand-edited.**

## Current unfinished step
**Account/sync reachability is the next privacy blocker; current-head Quality CI and Android Scenario 1 runtime verification remain incomplete.**

## FIRST NEXT STEP — exactly one
**Prove which legacy account/sync services are still reachable on the active branch, then delete only sources proven unreachable and re-check outbound endpoints before touching Android permissions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this state, the Master Map, and the affected specialized document with exact checkpoint, evidence, tests/run IDs, blocker and one first next step.