# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `bc928e2d6e21062acb324493d8637ac970935b7c`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Retired account callback/handoff cleanup is complete.
- Legacy snapshot-sync cluster is removed after reachability review.
- Orphaned generated `account_sync_repository.g.dart` was removed.
- Active Firefox Sync remains live through `features/sync` + native Mozilla Android Components; it was not touched by cleanup.
- Android `QUERY_ALL_PACKAGES` remains removed.
- Push background delivery and native fetch paths were mapped as active, intentional browser functionality.
- Current-head CI remains NOT VERIFIED.

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
- Orphaned legacy generated sync provider artifact removed.
- Active Firefox Sync retained.
- Automatic background feed fetch/headless entrypoint/direct dependency removed; manual foreground refresh retained.
- `QUERY_ALL_PACKAGES` removed; remaining permissions and `usesCleartextTraffic` require concrete branch-specific proof before changes.

## Outbound endpoint / background audit — current state
- Firefox Sync is delegated to Mozilla Android Components (`FxaAccountManager`, account-auth feature, `syncNow`, device constellation, native remote-tabs storage); no parallel hard-coded WebLibre Sync transport exists.
- UnifiedPush is an intentional background integration: receiver -> durable push store -> WorkManager worker -> Gecko web-push delivery. It must remain.
- `GeckoFetchApiImpl` is an active Pigeon bridge to the native Android Components fetch client, not a dead compatibility shell.
- `INTERNET` remains justified while these browser/network capabilities remain.
- `android:usesCleartextTraffic="true"` remains unchanged; current source evidence does not establish a safe global removal/narrowing.

## Permission audit
- `QUERY_ALL_PACKAGES`: removed and source-verified.
- `ACCESS_WIFI_STATE`: source comment identifies it as a Fenix debug-manifest capability; GitHub code search returned zero `WifiManager` hits but reported incomplete results, so deletion is not yet evidence-complete.
- Camera, microphone, location, media/storage, notifications and foreground-service permissions remain pending direct consumer mapping.
- No additional permission was removed in this checkpoint.

## Supabase configuration
`supabase_config.dart` remains because a known active subscription UI consumer uses its account portal URL, while repository-wide branch-scoped proof for the legacy Supabase constants is incomplete. Do not delete or rename it from incomplete search evidence alone.

## Release
Validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on runtime/release validation.

## Evidence rule
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED` are separate states.

## FIRST NEXT STEP — exactly one
**Finish branch-scoped consumer proof for `supabase_config.dart`, remaining app-level HTTP clients, and each Android permission; then apply only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
