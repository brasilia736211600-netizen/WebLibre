# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `82cc793eb69baf757fba4cf8548c2e21e3fe5f79`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Retired account callback/handoff cleanup is complete.
- Legacy snapshot-sync cluster is removed after reachability review.
- An orphaned generated `account_sync_repository.g.dart` left behind by the earlier cleanup was subsequently removed.
- Active Firefox Sync remains live through `features/sync` + native Mozilla Android Components; it was not touched by the cleanup.
- Android `QUERY_ALL_PACKAGES` remains removed.
- Current-head Actions query for the latest cleanup commit returned zero workflow runs; therefore CI is NOT VERIFIED.

## Browser / Android runtime
Scenario 1 remains **FAIL / runtime revalidation pending**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

A source lifecycle stabilization is committed in the branch. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice: `get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, source mappings and focused tests remain SOURCE-VERIFIED. Current-head Quality CI remains pending; AI-2 remains blocked.

## Privacy / personal-product hardening
- Legacy account callback/handoff path removed.
- Legacy snapshot-sync path removed after source reachability review.
- Active Firefox Sync retained.
- Automatic background feed fetch/headless entrypoint/direct dependency removed; manual foreground refresh retained.
- `QUERY_ALL_PACKAGES` removed; remaining permissions and `usesCleartextTraffic` require concrete feature/endpoint proof before changes.
- Orphaned legacy generated sync provider artifact removed.

## Outbound endpoint audit — checkpoint
- Active Firefox Sync delegates to Mozilla Android Components `FxaAccountManager`, account-auth features, explicit `syncNow(SyncReason.User)`, device constellation, and native remote-tabs storage.
- `FxaServer` selects the Android Components release server by default and permits explicit server/token overrides.
- There is no separate hard-coded WebLibre Firefox Sync HTTP transport in `GeckoSyncApiImpl`.
- `SupabaseConfig` still exists as an HTTPS-only configuration artifact for the retired account backend; it remains pending branch-specific consumer proof before deletion.
- `android:usesCleartextTraffic="true"` remains unchanged because endpoint-level HTTP use outside the browser engine has not yet been fully characterized.
- No additional manifest permission has been removed in this checkpoint.

## Release
Validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on runtime/release validation.

## Evidence rule
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED` are separate states.

## FIRST NEXT STEP — exactly one
**Finish the active-consumer audit for remaining app-level HTTP clients, Push/background paths, and concrete Android permission use; then apply only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
