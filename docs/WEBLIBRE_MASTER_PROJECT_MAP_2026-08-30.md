# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Current source HEAD:** `bc84f5cd0690fb6aa24eb4d8b7d348bab8bee375`

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
    Android runtime restore UA                  FAIL — Scenario 1

AI-1 Browser Tool
    specification / inventory / contracts       DONE / SOURCE-VERIFIED
    registry / executor / focused tests         SOURCE-VERIFIED; current Quality CI still pending
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
    Automatic background feed fetch             PENDING
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

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
The model-independent first slice is:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor and focused tests are source-verified. The Quality workflow contains the AI-1 registry/executor tests, but no Quality run has yet been verified against the exact live HEAD `bc84f5c...`.

## AI engineering orchestration
The durable continuity layer records role boundaries for:
- GitHub
- get-fable and selected fable lifecycle skills
- Codex Coordinator
- Codex Process Jobs
- Codex Engineering Guardrails
- CodeRabbit
- Codex Advisor
- AI DevKit
- Yaps Memory
- Prompt Optimizer
- security/review/verify/recover capabilities where relevant

Recommended high-value additions over the original stack are `fable-cowork` for complex bounded multi-step execution, `fable-loop` for bounded CI/status polling, `fable-verify` for fresh acceptance evidence, `fable-recover` for repeated/contradictory failures, `fable-handoff` for compact durable session state, and PR-completion/review skills when shepherding a PR through reviews and CI.

Do not invoke all skills on every task. Select the smallest useful set; keep YAGNI and avoid competing canonical memory stores.

## Release / APK
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Production `v*` releases remain blocked on browser runtime + release validation.

## Privacy boundary
Non-negotiable:
`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed browsing/search/feed/proxy/Tor/sharing is not automatically telemetry. App-level outbound paths must be classified as user-directed, explicitly opted-in, required for an enabled feature, or silent/unrequested.

The current privacy/account source changes were Flutter-build verified at `eea4b40...`; later documentation-only commits do not extend that verification to later source HEADs.

## CI evidence
- Flutter CICD run `33420348298` / job `99580917046`: SUCCESS on exact source checkpoint `eea4b40...`.
- Required stable APK build step: SUCCESS.
- Native gomobile runtime build: SUCCESS.
- Validation Release creation: SUCCESS.
- Quality #60 `33334955774` is SUCCESS on older `4771404...` and predates the AI-1 test-step addition.
- No current Quality run has been verified for `bc84f5c...`.
- Exact current HEAD status currently has zero published commit statuses / no associated PR-triggered workflow run, so it remains pending CI proof.

## Evidence rule
Never promote:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

A successful older run does not prove a later HEAD. `[x]` is not runtime proof. A ZIP artifact is not a direct Release asset.

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this map, Workflow State and the affected specialized document with exact HEAD, evidence, tests/run IDs, blocker and exactly one first next step.

## Current checkpoint
**Current source HEAD:** `bc84f5cd0690fb6aa24eb4d8b7d348bab8bee375`.
**Last known current-head CI:** none verified.
**Android:** Scenario 1 FAIL; UA restore remains runtime blocker.
**AI-1 Quality CI:** pending on current checkpoint.
**First next step:** obtain a current Quality run for the exact branch HEAD and verify AI-1 registry/executor plus targeted container/native tests; do not install an APK or start AI-2 until the browser foundation gates are satisfied.
