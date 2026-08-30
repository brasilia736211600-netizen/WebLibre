# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current execution HEAD:** `7af9350a8c867097700d4e13e6393a92c1480139`

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code, branch refs, commits, PRs, and CI. Never reconstruct state from chat.

### Browser / UA
Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal/multi/duplicate UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted container UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` applies persisted per-container UA at `LinkEngineSessionAction` and handles already-attached sessions through `AddTabAction`.
- Native creation paths apply UA to the prepared `EngineSession` before first navigation.
- No global GeckoRuntime UA, second DB, new recovery Pigeon field, or Android Components fork.

### Restore
UA cold-start/restored-tab integration is implemented in source but remains runtime-unverified. Restore retains `contextId`; existing `tab.db` and persisted `container.metadata` remain the sources of truth.

### Test surface
- Dart focused container metadata tests: 11/11 green.
- Native focused tests: `ContainerUserAgentStoreTest` and `ContainerProxyFeatureTest`.
- Quality #39 `33329515686` completed successfully against product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- AI-1 registry tests are added.
- AI-1 execution-boundary tests are added.
- Quality #54 `33334264690` is running against state-save checkpoint `6a73bcd1d1a478d38dd0fb17bd428b8b4b500de7`; it is stale relative to the current branch HEAD `7af9350a8c867097700d4e13e6393a92c1480139` and therefore is not current proof.
- No automated Android process-death/cold-start test; unit/CI tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch HEAD: `7af9350a8c867097700d4e13e6393a92c1480139`.
- AI-1 implementation checkpoint: `21f8ae8ab2b9a0385a7c0880280226d5034a5405`.
- PR #3: open, draft, not merged; base `main`.
- Actual PR head is branch-ref controlled and must be re-read; the PR description's older `901bf...` value is stale.
- Quality #39 `33329515686`: SUCCESS against the older product checkpoint.
- Quality #54 `33334264690`: IN_PROGRESS for `6a73bcd1d1a478d38dd0fb17bd428b8b4b500de7`; do not use as current evidence because its `head_sha` does not equal branch HEAD.
- A new current-head Quality run must be observed before claiming CI validation for `7af9350a8c867097700d4e13e6393a92c1480139`.
- Quality workflow uses per-PR/branch `concurrency` with `cancel-in-progress: true`, and excludes `.github/workflows/quality.yml` from normal PR path triggers.

## RUN INTERPRETATION RULE
A Quality run validates the `head_sha` captured at trigger time, not the branch HEAD seen later. Always inspect `head_sha` before using a result as current evidence.

## PARALLEL EXECUTION RULE
When an independent CI/build/test/run is waiting or in progress, do not remain idle. Use the interval for independent non-conflicting source/call-chain inspection, PR/review/issue inspection, release/build analysis, documentation consistency, or preparation of the next minimal change.

Rules:
1. Only run logically independent tasks alongside the active run.
2. Never perform two writes against the same file or dependent code path concurrently.
3. Never duplicate an active test/build without a concrete diagnostic reason.
4. Prefer read/analysis/review while CI executes.
5. Reconcile parallel findings with the active run before modifying code.
6. Never bypass dependency order or YAGNI.
7. If parallel work exposes a concrete blocker, fix only that first causal blocker.
8. Save material results to durable state before handoff.
9. Android device testing is a validation checkpoint, not a prerequisite for independent repository preparation. Complete buildable/tooling/design work in parallel, then perform the consolidated Android validation pass when the integrated build is ready.

## LAST COMPLETED STEP
Verified the six-tool first-slice APIs against the current source and implemented the minimal AI-1 execution boundary:
- `get_tabs` -> `tabListProvider` + `tabStatesProvider`.
- `get_current_tab` -> `selectedTabProvider` + `tabStatesProvider`.
- `create_tab` -> `TabRepository.addTab`.
- `switch_tab` -> `TabRepository.selectTab`.
- `close_tab` -> `TabRepository.closeTab`.
- `open_url` -> `GeckoSessionService(tabId: ...).loadUrl`.

The boundary performs registry lookup, declared-permission checking, typed dispatch, deterministic result/error envelopes, and a non-persistent audit event. It does not introduce an Agent runtime, model integration, new browser persistence, Pigeon changes, or Gecko internals exposed to the model.

## CURRENT UNFINISHED STEP
A. Browser runtime proof remains unverified on a real Android runtime:
- cold-start/restored-tab UA persistence;
- Container A/B UA isolation;
- Proxy A/B/fail-closed behavior.

B. AI-1 execution boundary and focused tests are implemented in source but are not yet CI-proven. The currently observed Quality run is stale relative to branch HEAD and must not be treated as validation of the current checkpoint.

## AI-1 CHECKPOINT
Inventory:
`docs/WEBLIBRE_AI1_BROWSER_TOOL_INVENTORY_2026-08-30.md`

Implementation:
- `apps/weblibre/lib/core/ai/tools/browser_tool_contract.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_registry.dart`
- `apps/weblibre/lib/core/ai/tools/browser_tool_executor.dart`
- `apps/weblibre/test/core/ai/tools/browser_tool_registry_test.dart`
- `apps/weblibre/test/core/ai/tools/browser_tool_executor_test.dart`

First slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

`open_url` now has an explicit typed `{tabId, url}` input rather than relying on an underspecified tab-id-only contract.

## EXACT NEXT EXECUTION
1. Observe the next Quality run and accept its result only when its `head_sha` equals `7af9350a8c867097700d4e13e6393a92c1480139`.
2. If that run reports a concrete AI-1 compile/test blocker, fix only that first causal blocker.
3. Do not expand the AI-1 tool surface yet.
4. Prepare the consolidated Android runtime validation path/checklist in parallel; do not require repeated APK downloads for each subtest.
5. Perform one consolidated Android validation pass covering UA restore, Container A/B isolation, and proxy behavior when the integrated build is ready.
6. Validate the existing split-ABI release path.
7. Continue to AI-2 only after AI-1 is tested and the browser foundation is runtime-validated.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, an Android Components fork, or unrelated refactors unless focused runtime/test evidence proves the current path insufficient.

Do not build the full Agent, memory, provider integration, Telegram/WhatsApp transport, or autonomous workflows during AI-1.

Do not treat source mapping or CI success as proof of real Android cold-start, UA isolation, or proxy fail-closed behavior.

## MASTER PROJECT MAP
`docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` is the durable high-level roadmap. Update it on every material milestone.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Current state-save HEAD:** `7af9350a8c867097700d4e13e6393a92c1480139`.
**AI-1 implementation checkpoint:** `21f8ae8ab2b9a0385a7c0880280226d5034a5405`.
**Latest verified Quality:** #39 `33329515686` GREEN against the older product checkpoint.
**Current observed Quality:** #54 `33334264690` IN_PROGRESS against `6a73bcd1d1a478d38dd0fb17bd428b8b4b500de7` and therefore stale for current HEAD.
**Current browser blocker:** real Android runtime validation.
**Current AI-1 status:** six-tool contract/registry + source-verified execution mappings + minimal execution boundary + focused tests implemented; current-head CI validation pending.