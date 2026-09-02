# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Source HEAD before this documentation commit:** `5c5e905ed563fd0419dc9b36894f4b205f4ecbb9`

## Durable documents
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
- `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`
- `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`
- `docs/WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md`
- `docs/WEBLIBRE_PRIVACY_DATA_FLOW_AUDIT_2026-08-31.md`
- `docs/WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`
- `docs/WEBLIBRE_AI_COORDINATION_AND_CONTINUITY_2026-09-02.md`
- `docs/WEBLIBRE_USER_OPERATING_RULES_2026-09-02.md`

## Current product position
```text
Browser / Container / UA foundation
    source + focused CI                         DONE / historical CI evidence only
    Android runtime restore UA                  FAIL — Scenario 1; source lifecycle stabilization committed, runtime revalidation pending

AI-1 Browser Tool
    specification / inventory / contracts       DONE / SOURCE-VERIFIED
    registry / executor / focused tests         SOURCE-VERIFIED; current Quality CI pending
    Agent Core                                  NOT STARTED

Privacy / Personal Product Hardening
    Account callback/handoff legacy path        REMOVED / SOURCE-VERIFIED
    Legacy snapshot-sync cluster                REMOVED / SOURCE-VERIFIED after reachability review
    Orphaned legacy generated sync artifact     REMOVED / SOURCE-VERIFIED
    Active Firefox Sync feature                 RETAINED / source-verified native FxaAccountManager path
    Legacy Supabase handoff client              REMOVED / SOURCE-VERIFIED
    Automatic background feed fetch             REMOVED FROM STARTUP
    Background headless feed entrypoint         REMOVED
    Direct background_fetch dependency          REMOVED FROM APP PUBSPEC
    Tracked pubspec.lock                        NOT PRESENT ON ACTIVE BRANCH
    Manual foreground feed refresh              RETAINED
    QUERY_ALL_PACKAGES permission               REMOVED / SOURCE-VERIFIED
    outbound app endpoint audit                 IN PROGRESS / Firefox Sync mapped; Push path mapped
    remaining permission/cleartext audit        PENDING concrete branch-specific consumer proof
    local privacy/data-flow screen             PENDING
```

## Outbound endpoint/background audit checkpoint
Active Firefox Sync is implemented through Mozilla Android Components. The WebLibre bridge calls `FxaAccountManager` for account/sync state, account-auth features for sign-in, `syncNow(SyncReason.User)`, device constellation operations, and native remote-tabs storage. `FxaServer` selects the Android Components release server by default and permits explicit server/token overrides. There is no separate hard-coded WebLibre Firefox Sync HTTP transport in `GeckoSyncApiImpl`.

UnifiedPush is an intentional background network integration: `UnifiedPushReceiver` receives distributor callbacks, persists decrypted messages, and schedules `PushMessageWorker`; the worker rehydrates profile-scoped components and calls the WebLibre Push integration to deliver the message into Gecko. This is a concrete user-enabled web-push path, not silent telemetry, and is retained.

`GeckoFetchApiImpl` is a native fetch bridge backed by `components.core.client`; it exposes the browser/Android Components fetch stack rather than a parallel raw Dart HTTP transport. Because browser requests can legitimately target HTTP URLs, this evidence is not enough by itself to disable `android:usesCleartextTraffic` globally.

The separate `SupabaseConfig` file still contains HTTPS build-time defaults for the retired account backend and remains an unresolved legacy configuration artifact because branch-scoped consumer proof is incomplete. Do not remove or rename it solely from default-branch search results.

## Android manifest safety boundary
Keep `INTERNET` and `ACCESS_NETWORK_STATE` while active browser/network features remain. Keep foreground service declarations for concrete DownloadService, PrivateTabsNotificationService, and MediaSessionService paths. Camera, microphone, location, media/storage, notification and `usesCleartextTraffic` remain pending direct consumer proof.

`ACCESS_WIFI_STATE` is currently declared with a source comment saying it is a Fenix debug-manifest capability. Branch code search did not return a concrete WebLibre `WifiManager` consumer, but the search endpoint reports incomplete indexing, so no manifest deletion was made from that search alone.

## Runtime blocker
The first real Android validation of the ARM64 validation Release proved:
- Container A restored.
- Its tab restored.
- Before process death the tab sent configured Chrome/120 UA.
- After relaunch restored navigation sent Gecko/Firefox 152 UA instead.
- No `Resume last tab` control was present in that post-relaunch state.

A source-only UA lifecycle stabilization is in the branch: `HistoryDelegateBindingMiddleware` receives the owning `ProfileContext` at construction and uses it during restore instead of resolving the global active profile per action. Do not run Scenarios 2–6 until Scenario 1 passes.

## AI engineering orchestration
Use the agreed add-ons only where they add leverage: GitHub as source-of-truth, Codex Engineering Guardrails for scoped implementation/verification, Coordinator/AI DevKit for parallel task boundaries when actual agent execution is available, Advisor for material architecture decisions, CodeRabbit for review, and Process Jobs for durable local processes. Do not create competing canonical state stores or invoke every skill unnecessarily.

## Release / APK
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs. Production `v*` releases remain blocked on browser runtime + release validation.

## CI evidence
- Historical Flutter CICD run `33420348298` / job `99580917046`: SUCCESS on exact older checkpoint `eea4b40...`.
- Historical Quality #60 `33334955774` succeeded on older `4771404...` and predates AI-1 test-step addition.
- Current source-head Actions queries made during this cycle returned zero runs for the latest cleanup commit; current-head CI remains NOT VERIFIED.
- The connector session exposes no workflow-dispatch action.

## Evidence rule
Never promote:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

## FIRST NEXT STEP — exactly one
**Finish branch-scoped consumer proof for `supabase_config.dart`, remaining app-level HTTP clients, Push/background paths, and each remaining Android permission; then apply only evidence-backed manifest/transport reductions.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
