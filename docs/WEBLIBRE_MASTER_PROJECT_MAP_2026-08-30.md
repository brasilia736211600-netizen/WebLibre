# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Current live HEAD:** `1382ea531a08a3954682b3c594f32842e354f88b`

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

## Current product position
```text
Browser / Container / UA foundation
    source + focused CI                         DONE / CI-VERIFIED for tested paths
    Android runtime restore UA                  FAIL — Scenario 1; source lifecycle stabilization added, runtime revalidation pending

AI-1 Browser Tool
    specification / inventory / contracts       DONE / SOURCE-VERIFIED
    registry / executor / focused tests         SOURCE-VERIFIED; current Quality CI pending
    Agent Core                                  NOT STARTED

Privacy / Personal Product Hardening
    About identity cleanup                      SOURCE-VERIFIED
    Account callback startup                   DISABLED
    Account/Firefox Sync Settings UI           REMOVED
    Account sign-in device_name                 REMOVED
    Sync source_device_id                      NULL-ENFORCED
    Direct Supabase application dependency     REMOVED
    Account auth/sync boundary                 SOURCE-VERIFIED + Flutter build verified on eea4b40...
    Search credits remote boundary             SOURCE-VERIFIED + Flutter build verified on eea4b40...
    Subscription remote boundary               SOURCE-VERIFIED + Flutter build verified on eea4b40...
    Search token issuance                      DISABLED
    Automatic background feed fetch             PENDING source edit
    Full dead account/sync source cleanup       PENDING reachability audit
    outbound endpoint audit                    PENDING
```

## Runtime blocker
The first real Android validation of the ARM64 validation Release proved:
- Container A restored.
- Its tab restored.
- Before process death the tab sent configured Chrome/120 UA.
- After relaunch restored navigation sent Gecko/Firefox 152 UA instead.
- No `Resume last tab` control was present in that post-relaunch state.

A source-only UA lifecycle stabilization was then committed: `HistoryDelegateBindingMiddleware` now captures the profile context when the middleware is constructed, instead of resolving the global active profile separately for each restore action. This remains unverified on-device.

Do not run Scenarios 2–6 until Scenario 1 passes.

## Android testing policy
Physical Android installation is a late-stage validation gate, not a development loop. Continue source inspection, focused tests, CI, static/reachability analysis, and review without waiting for the phone. Once the source/CI/review gates are sufficiently complete, perform one consolidated device validation pass; fix any issues found there and repeat only the affected final validation, rather than rebuilding/installing for every intermediate question.

## AI-1
The model-independent first slice is:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor and focused tests are source-verified. The current executor has an explicit terminal fallback return. Do not reapply the historical missing-return patch without fresh evidence. The Quality workflow contains AI-1 registry/executor tests, but no Quality run is currently verified against the live HEAD.

## AI engineering orchestration
The durable continuity layer records role boundaries for GitHub, get-fable, Codex Coordinator, Codex Process Jobs, Codex Engineering Guardrails, CodeRabbit, Codex Advisor, AI DevKit, Yaps Memory, Prompt Optimizer, and security/review/verify/recover capabilities where relevant.

Use only the smallest useful set. `fable-cowork` is for complex bounded autonomous chaining; `fable-loop` for bounded CI/status polling; `fable-verify` for fresh acceptance evidence; `fable-recover` for repeated/contradictory failures; `fable-handoff` for compact durable state. Do not create competing canonical memory stores or invoke every skill on every task.

## Release / APK
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Production `v*` releases remain blocked on browser runtime + release validation.

## Privacy boundary
Non-negotiable:
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed browsing/search/feed/proxy/Tor/sharing is not automatically telemetry. App-level outbound paths must be classified as user-directed, explicitly opted-in, required for an enabled feature, or silent/unrequested.

The current privacy/account source changes were Flutter-build verified at `eea4b40...`; later documentation commits do not extend that verification to later source HEADs.

## CI evidence
- Flutter CICD run `33420348298` / job `99580917046`: SUCCESS on exact source checkpoint `eea4b40...`.
- Required stable APK build step: SUCCESS.
- Native gomobile runtime build: SUCCESS.
- Validation Release creation: SUCCESS.
- Quality #60 `33334955774` is SUCCESS on older `4771404...` and predates the AI-1 test-step addition.
- Live HEAD `1382ea...` has no verified matching Quality run.
- The current Quality workflow has `workflow_dispatch`, but the current GitHub connector session exposes no workflow-dispatch action; do not claim a run was started from this session.

## Evidence rule
Never promote:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

A successful older run does not prove a later HEAD. `[x]` is not runtime proof. A ZIP artifact is not a direct Release asset.

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this map, Workflow State and the affected specialized document with exact HEAD, evidence, tests/run IDs, blocker and exactly one first next step.

## Current checkpoint
**Current live HEAD:** `1382ea531a08a3954682b3c594f32842e354f88b`.
**AI-1 Quality CI:** pending.
**Android:** Scenario 1 FAIL; source lifecycle stabilization committed, runtime verification still pending.
**Privacy:** source hardening largely complete but background feed, reachability, outbound, permission/cleartext, and local privacy screen audits remain pending.
**Device policy:** APK installation/testing remains deferred until the consolidated final validation gate.
**First next step:** continue independent source-level/reachability work and verification; keep physical APK installation deferred until the consolidated final validation gate.
