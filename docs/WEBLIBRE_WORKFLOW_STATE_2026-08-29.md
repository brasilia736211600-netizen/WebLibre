# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03  
**Branch:** `weblibre-ua-mainline-v3`  
**Current HEAD:** `0ef1bcf638a06daccd697465404c702e0d099df3` (`docs: record retired account callback and handoff cleanup checkpoint`)

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence. The GitHub branch ref is the final authority for the current HEAD because documentation commits necessarily advance the ref after they are written.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- The current branch contains the retired account callback/handoff cleanup through `0ef1bcf...`.
- `sharing_intent.dart` no longer parses account callbacks or exposes `accountCallbackStreamProvider`.
- The legacy callback handler and generated bindings are deleted.
- The `weblibre://account` Android deep link is deleted.
- The obsolete Supabase `handoff-redeem` client and generated provider are deleted.
- The active native Firefox Sync feature remains separate and live through `features/sync` + `GeckoSyncService`; it is not part of the deleted legacy handoff path.
- No verified current-head Quality run or commit status checks are available for `0ef1bcf...`.
- The GitHub connector session exposes no workflow-dispatch action.

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

Contracts, registry, executor, source mappings and focused tests are SOURCE-VERIFIED. The current `browser_tool_executor.dart` has an explicit terminal fallback return after dispatch. Current Quality CI proof remains pending; AI-2 remains blocked on current AI-1 CI plus browser runtime foundation validation.

## Privacy / personal-product hardening
The privacy/account source boundary remains SOURCE-VERIFIED with Flutter build verification on exact historical checkpoint `eea4b40...`. That older build does not verify the newer HEAD.

Background-fetch cleanup is complete at source level: release startup configuration, headless task registration, dedicated headless entrypoint, and direct app dependency are removed. Manual foreground feed refresh remains intentionally retained.

Account callback/handoff cleanup is now complete for the retired path: startup activation, callback parser/provider, callback stream, Android callback deep link, and legacy Supabase handoff client/provider are removed. The remaining account snapshot-sync cluster is still under reachability audit.

## Current unfinished step
**Finish reachability proof for the remaining legacy account snapshot-sync cluster, then complete outbound endpoint/background-service auditing.**

## FIRST NEXT STEP — exactly one
**Prove whether `prefs_sync_service`, `settings_sync_service`, `sync_document_service`, `SyncDocumentListSection`, and their legacy repository/widgets have any active-branch consumers; delete only the hard-proven dead cluster, then audit outbound endpoints before touching Android permissions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this state, the Master Map, and the affected specialized document with exact checkpoint, evidence, tests/run IDs, blocker and one first next step.