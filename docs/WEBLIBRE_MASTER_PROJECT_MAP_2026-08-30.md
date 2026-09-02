# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.  
**Branch:** `weblibre-ua-mainline-v3`  
**Current HEAD:** `6cfd17bb2c390d63beecab13d8ec6e7e23eeae21`

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
    Android runtime restore UA                  FAIL — Scenario 1; source lifecycle stabilization committed, runtime revalidation pending

AI-1 Browser Tool
    specification / inventory / contracts       DONE / SOURCE-VERIFIED
    registry / executor / focused tests         SOURCE-VERIFIED; current Quality CI pending
    Agent Core                                  NOT STARTED

Privacy / Personal Product Hardening
    Account callback/handoff legacy path        REMOVED / SOURCE-VERIFIED
    Active Firefox Sync feature                 RETAINED / native GeckoSyncService path
    Legacy Supabase handoff client              REMOVED / SOURCE-VERIFIED
    Automatic background feed fetch             REMOVED FROM STARTUP
    Background headless feed entrypoint         REMOVED
    Direct background_fetch dependency          REMOVED FROM APP PUBSPEC
    Tracked pubspec.lock                        NOT PRESENT ON ACTIVE BRANCH
    Manual foreground feed refresh              RETAINED
    QUERY_ALL_PACKAGES permission               REMOVED / SOURCE-VERIFIED
    Legacy account snapshot-sync cleanup        PENDING reachability audit
    outbound endpoint audit                    PENDING
    remaining permission/cleartext audit       PENDING
    local privacy/data-flow screen             PENDING
```

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
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for separate ARM64 and armeabi-v7a APKs.

Production `v*` releases remain blocked on browser runtime + release validation.

## CI evidence
- Flutter CICD run `33420348298` / job `99580917046`: SUCCESS on exact historical checkpoint `eea4b40...`.
- Historical Quality #60 `33334955774` succeeded on older `4771404...` and predates the AI-1 test-step addition.
- Current HEAD has no verified matching Quality run or commit status evidence.
- The current GitHub connector session exposes no workflow-dispatch action.

## Evidence rule
Never promote:
`SOURCE-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-ASSET-VERIFIED`.

## FIRST NEXT STEP — exactly one
**Prove whether the remaining legacy account snapshot-sync cluster has any active-branch consumers; remove only the hard-proven dead cluster, then complete the outbound endpoint/background-service audit before further Android permission/cleartext changes.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
