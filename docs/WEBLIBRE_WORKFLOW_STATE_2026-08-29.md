# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Last verified branch HEAD before this state-save:** `868299bf757c2db1e19630f1a4c9189f2b59a1ae`

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
- Quality #59 `33334940889` is queued against branch HEAD `868299bf757c2db1e19630f1a4c9189f2b59a1ae` and therefore is the current CI validation attempt for the restart-safe documentation checkpoint; queued/in-progress is not proof of success.
- No automated Android process-death/cold-start test; unit/CI tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Last verified branch HEAD before this state-save: `868299bf757c2db1e19630f1a4c9189f2b59a1ae`.
- Product-code checkpoint: `21f8ae8ab2b9a0385a7c0880280226d5034a5405`.
- PR #3: open, draft, not merged; base `main`.
- The PR description can contain an old head value; branch ref is authoritative.
- Quality #39 `33329515686`: SUCCESS against the older product checkpoint.
- Quality #59 `33334940889`: QUEUED with `head_sha=868299bf757c2db1e19630f1a4c9189f2b59a1ae`.
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
Persisted the restart-safe continuity protocol, added a canonical copy/paste resume command, and synchronized the master map/workflow state with the durable evidence rules.

Before this documentation synchronization, the last product-code step was the minimal AI-1 execution boundary with focused tests.

## CURRENT UNFINISHED STEP
A. Browser runtime proof remains unverified on a real Android runtime:
- cold-start/restored-tab UA persistence;
- Container A/B UA isolation;
- Proxy A/B/fail-closed behavior.

B. AI-1 execution boundary and focused tests are implemented in source but are not yet CI-verified on a successful current checkpoint.

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

## EXACT NEXT EXECUTION
1. Re-read the actual branch HEAD after this documentation commit and inspect the newest Quality run; accept CI proof only when `head_sha` exactly equals the actual branch HEAD and the run is successful.
2. If current-head Quality reports a concrete blocker, fix only the first causal blocker.
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
- verify actual branch/HEAD/PR/CI in GitHub;
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

Copy/paste resume command is stored in the canonical resume document and intentionally re-verifies the repository instead of trusting the saved SHA.

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
**Current verified pre-state-save HEAD:** `868299bf757c2db1e19630f1a4c9189f2b59a1ae`.
**Last product-code checkpoint:** `21f8ae8ab2b9a0385a7c0880280226d5034a5405`.
**Latest verified Quality:** #39 `33329515686` GREEN against the older product checkpoint.
**Current CI attempt:** Quality #59 `33334940889`, queued against `868299bf757c2db1e19630f1a4c9189f2b59a1ae`.
**Current browser blocker:** real Android runtime validation.
**Current AI-1 status:** six-tool contract/registry + source-verified execution mappings + minimal execution boundary + focused tests implemented; current-head CI validation pending.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.