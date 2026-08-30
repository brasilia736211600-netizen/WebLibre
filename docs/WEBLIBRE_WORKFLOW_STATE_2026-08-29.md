# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD at this state-save:** `91e9412a19b5882cee472ac5653456226ccdb20d`

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code, branch refs, commits, PRs, and CI. Never reconstruct state from chat.

### Browser / UA
Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal/multi/duplicate UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted per-container UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` applies persisted per-container UA at `LinkEngineSessionAction` and handles already-attached sessions through `AddTabAction`.
- Native creation paths apply UA to the prepared `EngineSession` before first navigation.
- No global GeckoRuntime UA, second DB, new recovery Pigeon field, or Android Components fork.

### Restore
UA cold-start/restored-tab integration is implemented in source but remains runtime-unverified. Restore retains `contextId`; existing `tab.db` and persisted `container.metadata` remain the sources of truth.

## EVIDENCE
- Dart focused container metadata tests: 11/11 green.
- Native focused tests: `ContainerUserAgentStoreTest` and `ContainerProxyFeatureTest`.
- Quality #39 `33329515686` completed successfully against product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- Quality #60 `33334955774` completed successfully against `477140419642d1170b241dd39f143900b9b98909`.
- Quality #60 is NOT AI-1 CI proof because its workflow revision predates the AI-1 test step.
- Quality #65 `33335697412` executed the new AI-1 test step against PR merge ref `896283de...`; the registry tests passed but the executor test file failed to compile because `BrowserToolExecutor.execute()` could fall through the `switch` without returning a `BrowserToolExecutionResult`.
- CI #65 also surfaced three pre-existing/missing asset directory warnings (`quotes`, `sites`, `ublock`); they did not cause the reported executor failure and are not being changed without evidence that they are causal.
- AI-1 registry tests and execution-boundary tests are present in source.
- AI-1 CI coverage was added to `.github/workflows/quality.yml` in commit `b6c866d2e372c2af1ff45b52003a6b469f4f8229`.
- The first AI-1 CI run therefore failed for a concrete Dart compile error, not because the test was absent.
- Executor fix committed as `91e9412a19b5882cee472ac5653456226ccdb20d`; it adds a deterministic post-switch fallback for a registered tool lacking an executor implementation.
- A new Quality run for `91e9412a...` has not yet appeared at this state-save.
- No automated Android process-death/cold-start test; unit/CI tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch HEAD: `91e9412a19b5882cee472ac5653456226ccdb20d`.
- PR #3: open, draft, not merged; base `main`; current PR head is `91e9412a...`.
- Quality #65 `33335697412`: FAILURE. It tested the PR merge ref `896283de...`, not the branch HEAD directly. The AI-1 registry tests passed; executor test compilation failed at `browser_tool_executor.dart:173` because the async method had a possible fall-through path.
- The fix is now in branch HEAD `91e9412a...`.
- Quality uses per-PR/branch concurrency with `cancel-in-progress: true`.

## RUN INTERPRETATION RULE
A Quality run validates the workflow revision and `head_sha` captured at trigger time, not the branch HEAD seen later. PR workflows may test the merge ref rather than the head commit. Always inspect both the checked-out ref/merge SHA and the PR head SHA before using a result as evidence.

## PARALLEL EXECUTION RULE
When an independent CI/build/test/run is waiting or in progress, do not remain idle. Use the interval for independent non-conflicting source/call-chain inspection, PR/review/issue inspection, release/build analysis, documentation consistency, or preparation of the next minimal change.

Rules:
1. Only run logically independent tasks alongside the active run.
2. Never perform two writes against the same file or dependent code path concurrently.
3. Never duplicate an active test/build without a concrete diagnostic reason.
4. Prefer read/analysis/review while CI executes.
5. Reconcile parallel findings with the active run before modifying code.
6. Never bypass dependency order or YAGNI.
7. If parallel work exposes a concrete blocker, fix only the first causal blocker.
8. Save material results to durable state before handoff.
9. Android device testing is a validation checkpoint, not a prerequisite for independent repository preparation. Complete buildable/tooling/design work in parallel, then perform the consolidated Android validation pass when the integrated build is ready.

## LAST COMPLETED STEP
Quality #65 reached and executed the new AI-1 registry/executor test step. The registry tests passed. The executor test exposed a concrete compile-time fall-through error in `BrowserToolExecutor.execute()`. That first causal blocker was fixed in `91e9412a...` with no architecture change.

## CURRENT UNFINISHED STEP
A. AI-1 CI verification: rerun/obtain a current Quality run containing the AI-1 focused tests and confirm success against the evaluated checkpoint.

B. Browser runtime proof remains unverified on a real Android runtime:
- cold-start/restored-tab UA persistence;
- Container A/B UA isolation;
- Proxy A/B/fail-closed behavior.

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

`open_url` has an explicit typed `{tabId, url}` input.

Execution boundary:
- registry lookup;
- declared-permission checking;
- typed dispatch;
- deterministic success/error envelopes;
- non-persistent audit event;
- no LLM logic;
- no direct Gecko/Pigeon/database exposure.

## EXACT NEXT EXECUTION
1. Obtain a current Quality run that executes both AI-1 focused tests against the current PR state; use only a successful run whose relevant checkout/head evidence matches the evaluated PR state.
2. If that run reports a concrete blocker, fix only the first causal blocker.
3. Do not expand the AI-1 tool surface while validation is pending.
4. Continue independent preparation of the single consolidated Android runtime validation path/checklist without requiring repeated APK downloads.
5. Perform one consolidated Android validation pass covering UA restore, Container A/B isolation, and proxy behavior when the integrated build is ready.
6. Validate the existing split-ABI release path.
7. Continue to AI-2 only after AI-1 is tested and the browser foundation is runtime-validated.

## RESUME / ANTI-AMNESIA PROTOCOL
Canonical resume document:
`docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`

Every new chat/agent must:
- read the canonical map, state, AI specification when relevant, and resume protocol;
- verify actual GitHub branch/HEAD/PR/CI;
- reconcile documentation against repository truth before editing;
- identify exactly one first next step;
- preserve evidence levels and dependency order;
- save exact SHA, tests, CI run/head_sha, blockers, and next step after every material milestone.

Evidence levels:
- `SOURCE-VERIFIED`
- `CI-VERIFIED`
- `ANDROID-RUNTIME-VERIFIED`
- `DOCUMENTED`

Never promote a lower evidence level to a higher one. `[x]` is a documentation marker, not runtime proof. Chat memory is never authoritative over GitHub.

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
**Branch:** `weblibre-ua-mainline-v3`
**Current state-save HEAD:** `91e9412a19b5882cee472ac5653456226ccdb20d`.
**Quality #65:** `33335697412` FAILED; registry tests passed, executor test compilation failed due to a possible fall-through return in `BrowserToolExecutor.execute()`.
**Fix commit:** `91e9412a19b5882cee472ac5653456226ccdb20d`.
**Current blocker:** current Quality proof for the fixed executor is pending.
**Browser blocker:** real Android runtime validation.
**Current AI-1 status:** six-tool contract/registry + source-verified mappings + minimal execution boundary + focused tests implemented; CI coverage added; first CI execution exposed and fixed one compile blocker; successful current CI execution pending.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.