# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD at this state-save:** `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`

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
- Quality #60 `33334955774` completed successfully against `477140419642d1170b241dd39f143900b9b98909`; it did not contain the AI-1 test step and therefore is not AI-1 CI proof.
- Quality #65 `33335697412` executed the AI-1 test step against PR merge ref `896283de...`; registry tests passed but executor compilation failed because `BrowserToolExecutor.execute()` could fall through the `switch`.
- The first causal executor compile blocker was fixed in `91e9412a19b5882cee472ac5653456226ccdb20d` with a deterministic fallback; no architecture change.
- A focused unknown-tool error-path test was added in `91e5e8d64f2d2d164251ae99af8a704392594a28`.
- Quality #66 `33335863267` for `91e9412a...` was cancelled before the AI-1 tests ran because the per-PR concurrency policy superseded it.
- Quality #70 `33335945926` completed successfully against branch commit `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`. Its `dart` job passed the AI-1 browser tool tests, targeted container tests, native gomobile build, and targeted native container tests. This is the current CI verification for the AI-1 execution boundary and the relevant integrated source checkpoint.
- No automated Android process-death/cold-start test; unit/CI tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch HEAD at this state-save: `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`.
- PR #3: open, draft, not merged; base `main`; current PR head was verified as the same checkpoint at the time of Quality #70.
- Quality #70 `33335945926`: SUCCESS. The run checked the exact branch commit `f05f643...`; AI-1 browser tool tests passed, along with targeted container/native checks.
- Quality uses per-PR/branch concurrency with `cancel-in-progress: true`.

## RUN INTERPRETATION RULE
A Quality run validates the workflow revision and `head_sha` captured at trigger time, not a later branch HEAD. PR workflows may test a merge ref rather than the head commit. Always inspect the checked-out ref/merge SHA and PR head SHA before using a result as evidence.

## PARALLEL EXECUTION RULE
When an independent CI/build/test/run is waiting or in progress, do not remain idle. Use the interval for independent non-conflicting source inspection, contract work, PR/review/issue inspection, release/build analysis, documentation consistency, or preparation of the next minimal change.

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
AI-1 minimal execution boundary is now CI-verified: Quality #70 `33335945926` succeeded against `f05f643...`, and the AI-1 browser tool test step passed. The earlier executor compile blocker was fixed and the deterministic unknown-tool error path is covered.

## CURRENT UNFINISHED STEP
A. Browser runtime proof remains unverified on a real Android runtime:
- cold-start/restored-tab UA persistence;
- Container A/B UA isolation across open, duplicate, and restore;
- Proxy A/B isolation and fail-closed behavior;
- no cross-container mutation.

B. Android/release validation must be consolidated into one meaningful integrated pass; do not require an APK for each subtest.

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
1. Do not expand AI-1: its current six-tool execution boundary is CI-verified.
2. Inspect the repository for the existing Android/release validation harness and determine exactly what can be exercised in one consolidated device pass; do not create a new harness unless the existing one is demonstrably insufficient.
3. Prepare only the minimum missing validation/documentation needed for that consolidated Android pass.
4. Perform the consolidated Android validation when the integrated build is ready, covering UA restore, Container A/B isolation, proxy behavior, fail-closed, and no cross-container mutation.
5. Validate the existing split-ABI release path.
6. Continue to AI-2 only after the browser foundation is Android-runtime-verified and AI-1 remains CI-verified.

## RESUME / ANTI-AMNESIA PROTOCOL
Canonical resume document:
`docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`

Every new chat/agent must:
- read the canonical map, state, AI specification when relevant, and resume protocol;
- verify actual GitHub branch/HEAD/PR/CI;
- reconcile documentation against repository truth before editing;
- identify exactly one first next step;
- preserve evidence levels and dependency order;
- save exact SHA, test evidence, CI run/head_sha, blockers, and next step after every material milestone.

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
**Current state-save HEAD:** `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`.
**Quality #70:** `33335945926` SUCCESS against `f05f643...`; AI-1 browser tool tests and targeted container/native checks passed.
**AI-1 status:** six-tool contract/registry + source-verified mappings + minimal execution boundary + focused tests + CI coverage + successful CI verification.
**Browser blocker:** real Android runtime validation.
**First next step:** inspect existing Android/release validation harness and identify the minimum missing pieces for one consolidated device pass.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
