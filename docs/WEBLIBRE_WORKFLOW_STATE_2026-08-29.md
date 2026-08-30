# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Execution HEAD at start of this state update:** `901bf4156b4b5b21bc8352c268b4e715ca73faa0`

## CURRENT EXECUTION TRUTH
GitHub is the source of truth for code, branch refs, commits, PRs, and CI. Never reconstruct state from chat.

### Browser / UA
Implemented and source-verified:
- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization.
- `AddTabParams.userAgent` source contract and generated bindings.
- Normal/multi/duplicate UA propagation.
- Existing per-container UA UI.
- `ContainerUserAgentStore.kt` resolves persisted container UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` applies persisted UA at `LinkEngineSessionAction` and handles already-attached sessions through `AddTabAction`.
- Native creation paths apply UA to the prepared `EngineSession` before first navigation.
- No global GeckoRuntime UA, second DB, new recovery Pigeon field, or Android Components fork.

### Restore
UA cold-start/restored-tab integration is implemented in source but remains runtime-unverified. Restore retains `contextId`; existing `tab.db` and persisted `container.metadata` remain the sources of truth.

### Test surface
- Dart focused container metadata tests: 11/11 green.
- Native focused tests: `ContainerUserAgentStoreTest` and `ContainerProxyFeatureTest`.
- Quality #39 `33329515686` completed successfully against product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`: Dart tests, NDK setup, pinned native checkout, gomobile runtime build, Gradle setup, and both targeted native tests passed.
- No automated Android process-death/cold-start test; unit tests cannot prove real Android process lifecycle behavior.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Last verified product checkpoint: `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- PR #3: open, draft, not merged; base `main`.
- Quality #39 `33329515686`: SUCCESS against product checkpoint `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
- Later commits may be documentation/state preparation only and must not be treated as product-code evidence.
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
7. If parallel work exposes a concrete blocker, fix only the first causal blocker.
8. Save material results to durable state before handoff.
9. Android device testing is a validation checkpoint, not a prerequisite for independent repository preparation. Complete buildable/tooling/design work in parallel, then perform the consolidated Android validation pass when the integrated build is ready.

## LAST COMPLETED STEP
Closed the CI prerequisite/scheduling problems and obtained a fully green Quality #39 on the product checkpoint. Then prepared the first AI-1 Browser Tool inventory from the existing source without implementing speculative Agent code.

## CURRENT UNFINISHED STEP
Two parallel tracks are active:

A. Browser runtime proof remains unverified on a real Android runtime:
- cold-start/restored-tab UA persistence;
- Container A/B UA isolation;
- Proxy A/B/fail-closed behavior.

B. AI-1 preparation has started at the documentation/contract-inventory level only. The baseline inventory is in `docs/WEBLIBRE_AI1_BROWSER_TOOL_INVENTORY_2026-08-30.md`. No Agent runtime, LLM, memory, or remote transport has been implemented.

## AI-1 PREPARATION CHECKPOINT
Created:
`docs/WEBLIBRE_AI1_BROWSER_TOOL_INVENTORY_2026-08-30.md`

The inventory identifies existing browser surfaces and defines the minimal first tool slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

The inventory deliberately avoids new persistence, model integration, remote transport, or unrestricted Gecko/Pigeon exposure.

## EXACT NEXT EXECUTION
1. Continue source-level verification of the six-tool AI-1 slice and identify exact existing APIs before writing the registry.
2. In parallel, prepare the consolidated Android runtime validation checklist/build path; do not require repeated APK downloads for each subtest.
3. Do not create another Quality run for docs-only changes.
4. If AI-1 source inspection finds stable existing APIs, implement only the minimal typed contract/registry vertical slice and targeted tests.
5. After the integrated browser/AI foundation is ready, perform one consolidated Android validation pass covering UA restore, A/B isolation, and proxy behavior.
6. Validate the existing split-ABI release path.
7. Continue to AI-2 only after AI-1 is tested and the browser foundation is runtime-validated.

## YAGNI / SAFETY BOUNDARY
Do not redo completed creation/UI work. Do not add `RecoverableTab.userAgent`, a new Pigeon API, a second DB, event-arrival freshness heuristics, global GeckoRuntime UA, an Android Components fork, or unrelated refactors unless focused runtime/test evidence proves the current path insufficient.

Do not build the full Agent, memory, provider integration, Telegram/WhatsApp transport, or autonomous workflows during AI-1.

## MASTER PROJECT MAP
`docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` is the durable high-level roadmap. Update it on every material milestone.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**State commit being created now:** documentation/state only.
**Latest product checkpoint:** `66e1dcf82f14333d4d7cd88c202a6e85aae13a4b`.
**Latest verified Quality:** #39 `33329515686` GREEN against that product checkpoint.
**Current product-code status:** no change in this state update.
**Current browser blocker:** real Android runtime/device validation.
**AI-1 status:** preparation/inventory started; implementation not yet started.
