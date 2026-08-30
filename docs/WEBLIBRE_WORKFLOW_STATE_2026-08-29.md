# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current branch HEAD at this state-save:** `290dcdeeb18a700c9408b6c2f1fc90290272d4f2`

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
- Current branch HEAD at state save: `290dcdeeb18a700c9408b6c2f1fc90290272d4f2`.
- PR #3: open, draft, not merged; base `main`.
- Quality #70 `33335945926`: SUCCESS against exact code checkpoint `f05f643...`; AI-1 browser tool tests and targeted container/native checks passed.
- Manual Flutter CICD run `33337359647`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact HEAD `26e96cfc...`; it produced the ZIP-only validation artifact `9739745969`.
- Direct-release-asset workflow implementation commit: `40abfb2a5f796e868bcd0ae0412ab521307166d2`.
- Documentation synchronization commit: `290dcdeeb18a700c9408b6c2f1fc90290272d4f2`.
- A fresh manual Flutter CICD run is now required to verify the new GitHub validation Release and direct APK assets; it has not yet been run at this state-save.

## MANUAL ANDROID ARTIFACT / RELEASE ASSET BUILD
The existing `.github/workflows/build.yml` has `workflow_dispatch` inputs `stable`, `alpha`, and `alphaLegacy`.

For `workflow_dispatch` it now:
- builds the selected APK using the existing build commands;
- uploads APKs as a workflow artifact;
- creates a GitHub **prerelease validation Release** containing the generated APK files directly;
- uses a unique validation tag containing variant, workflow run number, and commit SHA;
- never publishes a manual validation build to Google Play.

This direct-release behavior was implemented in commit `40abfb2a5f796e868bcd0ae0412ab521307166d2`.

For future production/stable publishing, the existing `v*` tag path remains the production path: it attaches stable split-ABI APKs and the AAB to the GitHub Release and publishes the AAB to Google Play internal track. Production versioning must wait until runtime/release validation is closed.

Previous manual stable build `33337359647` predates direct-release assets and therefore remains ZIP-only; do not treat it as proof of the new Release-asset behavior.

## ANDROID RUNTIME VALIDATION
A stable APK from the previous build exists and is suitable for runtime testing, but the project is deliberately taking a fresh build now so the direct APK Release assets can be verified at the same checkpoint.

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
AI-1 execution boundary reached CI-VERIFIED status via Quality #70. The release workflow was minimally extended first with manual validation builds, then with direct GitHub prerelease validation assets for manually triggered builds. The direct-release change is source-committed but awaits a fresh manual CI execution for verification.

## CURRENT UNFINISHED STEP
Fresh manual `stable` Flutter CICD verification of the direct GitHub validation Release assets:
- successful stable APK build;
- validation Release creation;
- both split-ABI APKs attached directly;
- exact asset names;
- exact triggering `head_sha`.

After that, real Android runtime proof remains pending.

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
2. Run a fresh manual `stable` Flutter CICD on `weblibre-ua-mainline-v3` using the updated `build.yml`.
3. Verify the resulting GitHub validation Release contains direct `app-stable-arm64-v8a-release.apk` and `app-stable-armeabi-v7a-release.apk` assets and that the Release/run SHA matches the built commit.
4. Use the ARM64 Release asset for the consolidated Android runtime checklist.
5. If a runtime scenario fails, preserve first causal evidence and inspect the existing call chain before changing code; do not add architecture speculatively.
6. Only after browser foundation is ANDROID-RUNTIME-VERIFIED, complete release validation and then continue to AI-2 Agent Core.

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

Do not treat a workflow artifact ZIP as equivalent to a direct GitHub Release asset; both must be recorded distinctly.

## MASTER PROJECT MAP
`docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` is the durable high-level roadmap. Update it on every material milestone.

## MANDATORY LOOP
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## CHECKPOINT
**Date:** 2026-08-30
**Branch:** `weblibre-ua-mainline-v3`
**Current state-save HEAD:** `290dcdeeb18a700c9408b6c2f1fc90290272d4f2`.
**AI-1 status:** six-tool contract/registry + source-verified mappings + minimal execution boundary + focused tests + CI coverage + successful CI verification via Quality #70 `33335945926` against `f05f643...`.
**Previous build status:** manual stable validation build `33337359647` SUCCESS at exact HEAD `26e96cfc...`; artifact `9739745969` is ZIP-only and predates direct Release asset support.
**Current release-asset status:** workflow support committed in `40abfb2...`; fresh manual CI verification pending.
**Runtime status:** consolidated six-scenario real-device validation is pending.
**Browser blocker:** real Android runtime validation.
**First next step:** run fresh manual `stable` Flutter CICD on `weblibre-ua-mainline-v3`; verify direct APK Release assets and exact SHA, then use the ARM64 asset for runtime validation.
**Resume protocol:** `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
