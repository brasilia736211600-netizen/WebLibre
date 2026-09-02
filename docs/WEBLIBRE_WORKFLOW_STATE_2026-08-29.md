# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03  
**Branch:** `weblibre-ua-mainline-v3`  
**Current HEAD:** `5c811022f46e92280cd52e4f99c66dd760aa001d` (`docs: record Android permission minimization checkpoint`)

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence. The GitHub branch ref is the final authority for the current HEAD because documentation commits necessarily advance the branch ref after they are written.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Retired account callback/handoff cleanup is complete: callback parser/provider, callback stream, Android callback deep link, and legacy Supabase handoff client/provider are deleted.
- Active Firefox Sync remains separate and live through `features/sync` + `GeckoSyncService`.
- Android `QUERY_ALL_PACKAGES` permission has been removed from the main app manifest; narrower intent-query declarations remain.
- No verified current-head Quality run or commit status checks are available for this checkpoint.
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

Contracts, registry, executor, source mappings and focused tests are SOURCE-VERIFIED. Current Quality CI proof remains pending; AI-2 remains blocked on current AI-1 CI plus browser runtime foundation validation.

## Privacy / personal-product hardening
Background-fetch cleanup is complete at source level: release startup configuration, headless task registration, dedicated headless entrypoint, and direct app dependency are removed. Manual foreground feed refresh remains retained.

Account callback/handoff cleanup is complete for the retired path. The remaining account snapshot-sync cluster is still under reachability audit.

Android package-visibility minimization has started: `QUERY_ALL_PACKAGES` is removed. Other permissions and cleartext traffic remain unchanged pending concrete feature/endpoint proof.

## Current unfinished step
**Finish reachability proof for the remaining legacy account snapshot-sync cluster, then complete outbound endpoint/background-service auditing.**

## FIRST NEXT STEP — exactly one
**Prove whether `prefs_sync_service`, `settings_sync_service`, `sync_document_service`, `SyncDocumentListSection`, and their legacy repository/widgets have any active-branch consumers; delete only the hard-proven dead cluster, then audit outbound endpoints before further Android permission/cleartext changes.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this state, the Master Map, and the affected specialized document with exact checkpoint, evidence, tests/run IDs, blocker and one first next step.