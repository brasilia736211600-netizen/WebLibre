# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-03
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `c7308fcc0c47ba522b95192826f3a155e600b9e1`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- Retired account callback/handoff cleanup is complete.
- Legacy snapshot-sync cluster is removed after reachability review.
- Orphaned generated `account_sync_repository.g.dart` was removed.
- Retired Supabase URL/anon-key constants were removed; only the account portal URL remains in the compatibility config because the subscription UI still links to that portal.
- The legacy account route is now informational-only; the obsolete account-auth repository, generated provider, state model/generated file, and auth card were removed.
- Active Firefox Sync remains live through `features/sync` + native Mozilla Android Components; it was not touched by the cleanup.
- Android `QUERY_ALL_PACKAGES` remains removed.
- Push background delivery and native fetch paths are mapped as active, intentional browser functionality.
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
- `QUERY_ALL_PACKAGES` removed.
- Retired Supabase credential/config fields removed; account portal origin retained for its live UI consumer.
- Retired account auth UI/repository/state cluster removed after the account route was reduced to informational-only behavior.

## Outbound endpoint / background audit
- Firefox Sync delegates to Mozilla Android Components `FxaAccountManager`, account-auth features, explicit `syncNow(SyncReason.User)`, device constellation, and native remote-tabs storage.
- UnifiedPush is an intentional user-enabled background delivery path: distributor receiver -> durable push store -> WorkManager worker -> Gecko delivery.
- `GeckoFetchApiImpl` is an active Pigeon bridge to the native Android Components fetch client.
- `DownloadService` uses the shared Android Components HTTP client.
- `android:usesCleartextTraffic="true"` remains unchanged because browser HTTP support and app-level HTTP transports have not yet been fully separated by evidence.

## Android permission audit boundary
- `INTERNET` and `ACCESS_NETWORK_STATE` remain justified by active browser/network features.
- Foreground-service declarations remain justified by concrete download, private-tab notification, and media-session integrations.
- `ACCESS_WIFI_STATE` remains unchanged because the available code-search response is incomplete despite returning no concrete `WifiManager` hit.
- Camera, microphone, location, media/storage and notification permissions remain pending direct branch-specific consumer proof.

## Release
Validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on runtime/release validation.

## Evidence rule
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED` are separate states.

## FIRST NEXT STEP — exactly one
**Finish branch-scoped direct consumer proof for the remaining Android permissions and any remaining app-level HTTP/configuration consumers; then make only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
