# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Last synchronized HEAD:** `4ec62dd318738e905cc94f2613b6b40423d67e15`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence. The GitHub branch ref is the final authority for the current HEAD because documentation commits necessarily advance the ref after they are written.

## Verified current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Last synchronized branch checkpoint is `4ec62dd318738e905cc94f2613b6b40423d67e15`; the branch ref may advance by documentation-only commits after this file is written.
- The current Quality workflow contains AI-1 registry/executor tests and targeted container/native tests.
- No verified current-head Quality run or commit status checks are available for the synchronized checkpoint.
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
The existing privacy/account source boundary remains SOURCE-VERIFIED with Flutter build verification on exact checkpoint `eea4b40...`. Documentation/source commits after that checkpoint do not extend build evidence to the newer HEAD.

The automatic release-startup/background headless feed refresh path has been removed at source level: production `BackgroundFetch.configure`, the headless task registration, the dedicated headless entrypoint, and the direct `background_fetch` app dependency are removed. Manual foreground feed refresh remains intentionally retained.

Still pending: pub/lockfile verification, hidden account/sync initializer reachability audit, dead-source cleanup after reachability proof, outbound endpoint/background-service audit, Android permission/cleartext minimization review, local privacy/data-flow screen, and Android UA Scenario 1 root-cause fix/revalidation.

## UA source checkpoint
The current UA restore path captures `GlobalComponents.components?.profileApplicationContext` at `HistoryDelegateBindingMiddleware` construction instead of looking it up again for every restore action. This is a SOURCE-VERIFIED lifecycle stabilization only; the Android Scenario 1 result is not promoted until fresh runtime evidence confirms the behavior.

## Device-build policy
Physical Android installation/testing is intentionally deferred until the highest-value source/CI/review work is complete. Do **not** generate/install an APK merely to re-run an already-unverified source question. The intended device phase is one consolidated validation pass near release readiness.

## Last completed step
**Removed automatic background feed refresh and its dedicated headless plumbing, synchronized the privacy audit and Master Map, and verified the resulting diff is limited to the intended three source files plus durable documentation:** `4ec62dd318738e905cc94f2613b6b40423d67e15`.

## Current unfinished step
**Pub/lockfile verification is the immediate blocker for the privacy milestone; current-head Quality CI and Android Scenario 1 runtime verification remain incomplete.**

## FIRST NEXT STEP — exactly one
**Run dependency/lockfile verification for the background-fetch removal before any further privacy edits, then continue the smallest reachable source audit supported by that evidence.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this state, the Master Map, and the affected specialized document with exact checkpoint, evidence, tests/run IDs, blocker and one first next step.
