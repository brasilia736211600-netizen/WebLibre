# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-05
**Branch:** `weblibre-ua-mainline-v3`
**Current source/workflow HEAD:** `8a407ea47ef855bf08d722d52d63dcc4f08d3da7`
**Functional code checkpoint:** `8089e68a60f40cef6f36943fb8489e349290d951`

## Source of truth
GitHub code, refs, commits, CI/build/release runs, artifacts and release assets are authoritative. Chat memory is not evidence.

## Current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`, current head `8a407ea47ef855bf08d722d52d63dcc4f08d3da7`.
- The functional UA correction is `ContainerUserAgentCreateSessionMiddleware`: it creates the restored session, applies the persisted container UA before `restoreState()`, reapplies it defensively, then links the session.
- The follow-up lifecycle hardening at `8089e68a60f40cef6f36943fb8489e349290d951` re-reads the tab from live store state after coroutine scheduling to reduce stale-state races.
- AI-1 remains a six-tool model-independent Browser Tool slice with explicit permissions, side-effect metadata, deterministic errors, audit callback, and focused regression coverage.
- Quality run #92 (`33998587053`) is executing against `ae5463fbd647b9a3ae9922f6578d2b3ed2c2480e`; AI-1 tests and targeted container tests have passed and native runtime build is in progress. No final conclusion has been claimed yet.
- The later commits `8a407ea47ef855bf08d722d52d63dcc4f08d3da7` and its validation-workflow parent are workflow-only/hardening changes; no browser source behavior was changed after the functional checkpoint.

## Browser / Android runtime
Scenario 1 remains **FAIL / runtime revalidation pending**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No usable `Resume last tab` control was present in the prior post-relaunch state.

The current lifecycle fix remains source-verified but has no fresh Android-runtime evidence. Do not run Scenarios 2–6 until Scenario 1 passes.

## Validation APK / emulator gate
`.github/workflows/validation-apk.yml` is now strengthened to:
- build stable split APKs and a stable debug APK;
- upload both as a SHA-named workflow artifact;
- install the debug APK on an API 35 x86_64 emulator;
- assert SDK/package installation;
- launch, assert live process and resumed activity, check the crash buffer, force-stop, and relaunch;
- always upload emulator logcat for diagnosis;
- trigger on branch pushes and on relevant PR changes.

The available GitHub connector exposes PR-triggered workflow runs, but workflow-dispatch is not exposed. Therefore no current validation APK artifact is claimed until a retrievable exact-head run exists.

## AI-1
Six-tool model-independent Browser Tool slice: `get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, mappings and focused tests remain SOURCE-VERIFIED. Quality run #92 has already passed the AI-1 and targeted container stages on `ae5463f...`; the full run is still pending.

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
**Obtain a retrievable exact-head validation workflow run; then verify its APK artifact and Android API 35 smoke result, and only after that execute Scenario 1.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`