# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD at this state-save:** `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`

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
- Quality #65 `33335697412` exposed an executor compile blocker; it was fixed in `91e9412a...` and the deterministic unknown-tool path was hardened in `91e5e8d...`.
- Quality #70 `33335945926` completed successfully against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`. Its Dart job ran the AI-1 browser tool tests, targeted container tests, native gomobile build, and targeted native container tests successfully. AI-1 execution boundary is therefore CI-VERIFIED at that checkpoint.
- No automated Android process-death/cold-start test; unit/CI tests cannot prove real Android process lifecycle or real-device proxy behavior.
- Repository inspection found no dedicated `integration_test` Android runtime harness.
- Consolidated device validation checklist: `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

## GIT / PR / CI
- Branch: `weblibre-ua-mainline-v3`.
- Current branch HEAD: `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
- PR #3: open, draft, not merged; base `main`.
- Quality #70 `33335945926`: SUCCESS against exact code checkpoint `f05f643...`; AI-1 browser tool tests and targeted container/native checks passed.
- Manual Flutter CICD run `33337359647`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact HEAD `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
- Manual build job `99326557994`: native gomobile runtime build SUCCESS; stable APK build SUCCESS; APK artifact upload SUCCESS; release/Play publication skipped as intended.
- Artifact: `weblibre-stable-apk-26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`, artifact id `9739745969`, SHA-256 `95e399057371d143e08784330280fb8b5106ffb4ec5dd06c35fe952d9703329f`, not expired.
- Commits after the AI-1 CI checkpoint are documentation/CI-operational changes only; no product runtime architecture changes were introduced.
- Quality uses per-PR/branch concurrency with `cancel-in-progress: true`.

## MANUAL ANDROID ARTIFACT BUILD
The existing `.github/workflows/build.yml` previously triggered only on `v*` tags. A minimal CI-operational path was added:
- `workflow_dispatch` input `build_type`: `stable`, `alpha`, or `alphaLegacy`.
- Manual builds compile the selected APK using the existing build commands.
- Manual builds upload APKs as workflow artifacts.
- Manual builds explicitly skip GitHub Release creation and Google Play publication.
- Existing tag-triggered release behavior remains unchanged.

Commit introducing this path: `01bf9c0e037145963bb81bca88973f712d8bfa69`.
Manual validation build completed successfully in run `33337359647` at HEAD `26e96cfc...`.

This is CI plumbing only; it does not constitute Android runtime proof and does not change product architecture.

## ANDROID RUNTIME VALIDATION
A single integrated stable APK is now available from the successful manual build. The APK is the exact artifact associated with HEAD `26e96cfc...`; do not build a new APK for individual checklist scenarios.

Checklist: `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

Runtime scenarios remain pending:
1. cold-start/restored-tab UA persistence;
2. Container A/B UA isolation across open, duplicate, and restored tabs;
3. Restore isolation;
4. Proxy A/B isolation;
5. Proxy fail-closed;
6. no cross-container mutation.

Required evidence: exact APK/build identifier, app version/commit, device model/Android version, timestamp, observed outcomes, pass/fail, and logs/screenshots for failures.

## RUN INTERPRETATION RULE
A Quality/build run validates the workflow revision and `head_sha` captured at trigger time, not a later branch HEAD. PR workflows may test a merge ref rather than the head commit. Always inspect the checked-out ref/head evidence before using a result as evidence.

## PARALLEL EXECUTION RULE
When an independent CI/build/test/run is waiting or in progress, do not remain idle. Use the interval for independent non-conflicting source inspection, release analysis, or documentation. Never duplicate an active build, write the same file concurrently, bypass dependency order, or violate YAGNI.

## LAST COMPLETED STEP
AI-1 execution boundary reached CI-VERIFIED status via Quality #70. The existing release workflow was minimally extended with a manual validation-build trigger. A manual `stable` build was then successfully executed on the exact current branch HEAD, producing the validation APK artifact.

## CURRENT UNFINISHED STEP
Real Android runtime proof remains pending on the produced integrated APK:
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
2. Use the already-produced stable APK artifact `9739745969` from run `33337359647`; do not create another APK for individual scenarios.
3. Execute the consolidated Android runtime checklist on a real Android device.
4. If a runtime scenario fails, preserve first causal evidence and inspect the existing call chain before changing code; do not add architecture speculatively.
5. Only after browser foundation is ANDROID-RUNTIME-VERIFIED, complete release validation and then continue to AI-2 Agent Core.

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
**Current state-save HEAD:** `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
**AI-1 status:** six-tool contract/registry + source-verified mappings + minimal execution boundary + focused tests + CI coverage + successful CI verification via Quality #70 `33335945926` against `f05f643...`.
**Build status:** manual stable validation build `33337359647` SUCCESS at exact HEAD `26e96cfc...`; artifact `9739745969` exists with SHA-256 `95e399057371d143e08784330280fb8b5106ffb4ec5dd06c35fe952d9703329f`.
**Runtime status:** consolidated six-scenario real-device validation is pending; no dedicated Android integration harness exists.
**Browser blocker:** real Android runtime validation.
**First next step:** install/use the already-produced stable APK and execute the consolidated Android runtime checklist; do not repeat APK builds per subtest.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
