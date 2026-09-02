# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `478bc6ad4c8fb3b008e44e1c8de20e2527e1fac7`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Retired account callback/handoff cleanup is complete.
- Legacy snapshot-sync cluster is now removed after reachability review: snapshot UI widgets, `AccountSyncRepository`, `SyncDocumentService`, `PrefsSyncService`, `SettingsSyncService`, their generated providers, and `SettingsSyncEnvelope` model/generated file.
- The current account compatibility screen imports `account_auth` and `AccountAuthStatusCard` only; it does not import the removed snapshot-sync path.
- Active Firefox Sync remains live through `features/sync` + `GeckoSyncService`; it was not touched by this cleanup.
- Android `QUERY_ALL_PACKAGES` remains removed.
- Current-head GitHub Actions query for the post-cleanup source head returned zero workflow runs; therefore CI is NOT VERIFIED.

## Browser / Android runtime
Scenario 1 remains **FAIL / runtime revalidation pending**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice: `get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, source mappings and focused tests remain SOURCE-VERIFIED. Current-head Quality CI remains pending; AI-2 remains blocked.

## Privacy / personal-product hardening
- Legacy account callback/handoff path removed.
- Legacy snapshot-sync path removed after source reachability review.
- Active Firefox Sync retained.
- Automatic background feed fetch/headless entrypoint/direct dependency removed; manual foreground refresh retained.
- `QUERY_ALL_PACKAGES` removed; remaining permissions and `usesCleartextTraffic` require concrete feature/endpoint proof before changes.

## Release
Validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on runtime/release validation.

## Evidence rule
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED` are separate states.

## FIRST NEXT STEP — exactly one
**Complete the outbound endpoint/background-service audit, then use its concrete evidence to minimize remaining Android permissions/cleartext settings without speculative removals.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
