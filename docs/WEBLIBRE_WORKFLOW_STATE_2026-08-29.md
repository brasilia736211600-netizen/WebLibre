# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD at this state-save:** `ac2f4a815e4e65a2762d25f2de3229215ee6b1d5`

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
- Executor compile blocker fixed in `91e9412a19b5882cee472ac5653456226ccdb20d`; deterministic unknown-tool error-path test added in `91e5e8d64f2d2d164251ae99af8a704392594a28`.
- Quality #66 `33335863267` for the fix commit was cancelled by per-PR concurrency before AI-1 tests ran.
- Quality #70 `33335945926` completed successfully against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`. Its Dart job successfully ran the AI-1 browser tool tests, targeted container tests, native gomobile build, and targeted native container tests. AI-1 execution boundary is therefore CI-VERIFIED at that checkpoint.
- No automated Android process-death/cold-start test; unit/CI tests cannot prove real Android process lifecycle or real-device proxy behavior.
- Repository inspection found only the existing `build.yml` release workflow and normal Flutter/native test tree; no dedicated `integration_test` Android runtime harness exists. The release workflow builds APK/AAB on version tags; it does not perform real-device validation.
- Consolidated device validation checklist added at `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch HEAD at this state-save: `ac2f4a815e4e65a2762d25f2de3229215ee6b1d5`.
- PR #3: open, draft, not merged; base `main`.
- Quality #70 `33335945926`: SUCCESS against the exact code checkpoint `f05f643...`; AI-1 browser tool tests and targeted container/native checks passed.
- Commits after that checkpoint are documentation-only: state synchronization followed by the Android runtime checklist and this state synchronization. No product-code changes were introduced after the CI-verified AI-1 checkpoint.
- Quality uses per-PR/branch concurrency with `cancel-in-progress: true`.

## RUN INTERPRETATION RULE
A Quality run validates the workflow revision and `head_sha` captured at trigger time, not a later branch HEAD. PR workflows may test a merge ref rather than the head commit. Always inspect the checked-out ref/merge SHA and PR head SHA before using a result as evidence.

## PARALLEL EXECUTION RULE
When an independent CI/build/test/run is waiting or in progress, do not remain idle. Use the interval for independent non-conflicting source inspection, release analysis, or documentation. Never duplicate an active build, write the same file concurrently, bypass dependency order, or violate YAGNI.

## LAST COMPLETED STEP
AI-1 execution boundary reached CI-VERIFIED status via Quality #70. Repository inspection then confirmed that there is no dedicated Android integration/runtime harness. The existing release workflow can produce the integrated APK/AAB, while real-device behavior remains a manual consolidated checkpoint. A precise six-scenario device checklist is now stored in `WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

## CURRENT UNFINISHED STEP
Real Android runtime proof remains pending:
- cold-start/restored-tab UA persistence;
- Container A/B UA isolation across open, duplicate, and restore;
- Proxy A/B isolation and fail-closed behavior;
- no cross-container mutation.

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

`open_url` has explicit typed `{tabId, url}` input.

Execution boundary:
- registry lookup;
- declared-permission checking;
- typed dispatch;
- deterministic success/error envelopes;
- non-persistent audit event;
- no LLM logic;
- no direct Gecko/Pigeon/database exposure.

## EXACT NEXT EXECUTION
1. Do not expand AI-1; its current six-tool execution boundary is CI-VERIFIED.
2. Do not create an Android integration harness unless a concrete need emerges; the existing repository lacks one, and the current validation requirement is manual real-device behavior.
3. Produce/use one integrated APK from the existing build/release path when ready and execute the six-scenario consolidated Android checklist.
4. If a runtime scenario fails, preserve the first causal evidence and inspect the existing call chain before changing code; do not add architecture speculatively.
5. Only after the browser foundation is ANDROID-RUNTIME-VERIFIED, complete release validation and then continue to AI-2 Agent Core.

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
**Current state-save HEAD:** `ac2f4a815e4e65a2762d25f2de3229215ee6b1d5`.
**Quality #70:** `33335945926` SUCCESS against `f05f643...`; AI-1 browser tool tests and targeted container/native checks passed.
**AI-1 status:** six-tool contract/registry + source-verified mappings + minimal execution boundary + focused tests + CI coverage + successful CI verification.
**Runtime status:** no dedicated Android integration harness exists; consolidated real-device validation checklist is documented and ready.
**Browser blocker:** real Android runtime validation.
**First next step:** obtain/use one integrated APK and execute the consolidated Android runtime checklist; do not repeat per-subtest APK cycles.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
