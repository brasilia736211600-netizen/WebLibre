# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-05
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD at current checkpoint:** `e0e1124a9b969f7412f1642ccd6aafd8702b3faf`
**Functional code checkpoint:** `3be7de126e6342a2ade388a897c5e51674acb018`

## Source of truth
GitHub code, refs, commits, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`.
- The latest functional UA change remains at `3be7de126e6342a2ade388a897c5e51674acb018`; later commits preserve durable state and build hygiene.
- `ContainerUserAgentCreateSessionMiddleware` remains the source-level lifecycle correction: it creates the restored session, applies persisted container UA before `restoreState()`, reapplies it defensively, then links the session.
- AI-1 remains a six-tool model-independent Browser Tool slice with explicit permissions, side-effect metadata, deterministic errors, audit callback, and focused regression coverage.
- Quality run #79 (`33901450964`) tested the merge ref for PR #3 and FAILED during AI-1 tests because `SupporterHomeBanner` still imported the deleted `account_auth.dart` repository/provider. The same run also reported missing declared asset directories `assets/quotes/`, `assets/sites/`, and `assets/ublock/` during Flutter package setup.
- The account compile dependency was corrected in `1de32328ac4af22058ba6506037a9add1f2a61a7` by moving `SupporterHomeBanner` to the retained local `SubscriptionRepository` boundary and removing the deleted auth dependency.
- The three declared asset directories were restored as Git-tracked placeholders in commits `c09b2f4ea3277736834e3d15cb639299faf28a3d`, `4b533448035027cf85539ad6e9aea46d64fab952`, and `e0e1124a9b969f7412f1642ccd6aafd8702b3faf`.
- A new Quality run #83 (`33983996063`) is now running on the latest branch head. It has not yet reached the AI-1 test step, so the fixes are NOT CI-VERIFIED yet.

## Browser / Android runtime
Scenario 1 remains **FAIL / runtime revalidation pending**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No usable `Resume last tab` control was present in the prior post-relaunch state.

The lifecycle fix intended to close this failure is source-committed but not yet CI- or Android-runtime-verified. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice: `get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, mappings and focused tests remain SOURCE-VERIFIED. Quality must pass on the current branch before AI-2 starts.

## Privacy / personal-product hardening
- Legacy account callback/handoff cleanup remains removed.
- Legacy snapshot-sync cluster remains removed after reachability review.
- Active Firefox Sync remains intact.
- Automatic background feed fetch/headless entrypoint/direct dependency remains removed; manual foreground refresh remains.
- `QUERY_ALL_PACKAGES` remains removed.
- Obsolete Supabase credential/configuration material remains removed; account portal compatibility remains where still consumed.
- Legacy account-auth repository/state/UI cluster remains removed.
- `CAMERA`, microphone, location, and notification permissions remain justified by active runtime paths.

## Outbound endpoint/background audit
- Active Firefox Sync uses native Android Components sync/account infrastructure.
- UnifiedPush remains a concrete user-enabled background delivery path.
- `GeckoFetchApiImpl` remains active.
- `Core.client` remains wired into active icon/add-on/web-app/copy/share/download browser features.
- `DownloadService` uses the Android Components HTTP client.
- `android:usesCleartextTraffic="true"` remains unchanged pending complete transport separation evidence.

## Android permission audit boundary
- `INTERNET` and `ACCESS_NETWORK_STATE` remain justified.
- Foreground-service declarations remain justified by active download/private-tab/media integrations.
- `CAMERA` is source-verified for QR scanning.
- Native site permission handling covers camera, location, notification, and microphone.
- `POST_NOTIFICATIONS` has an explicit app-level request path.
- `ACCESS_WIFI_STATE` remains unchanged pending stronger branch-scoped attribution.
- Legacy storage/media permission declarations remain pending finer attribution.

## Release
Validation release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on runtime/release validation.

## Evidence rule
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED` are separate states.

## FIRST NEXT STEP — exactly one
**Validate Quality run #83 on the latest head; if green, generate the consolidated validation APK and execute Android Scenario 1.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`