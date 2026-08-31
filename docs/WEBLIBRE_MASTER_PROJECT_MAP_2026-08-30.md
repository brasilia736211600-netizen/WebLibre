# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.  
**Branch:** `weblibre-ua-mainline-v3`  
**Current source HEAD at this state-save:** `bf374d10faced96467605f8571f28db1fc85022f`  

## Canonical durable documents

- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
- `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`
- `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`
- `docs/WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md`
- `docs/WEBLIBRE_PRIVACY_DATA_FLOW_AUDIT_2026-08-31.md`
- `docs/WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`

## Current product position

```text
Browser / Container / UA foundation
    source + focused CI                         DONE
    Android runtime restore UA                  FAIL — Scenario 1

AI-1 Browser Tool
    specification / inventory / contracts       DONE
    registry / executor / focused tests         CI-VERIFIED
    Agent Core                                  NOT STARTED

Privacy / Personal Product Hardening
    About identity cleanup                      DONE
    Account callback startup                   REMOVED
    Account/Firefox Sync Settings UI           REMOVED
    Account sign-in device_name                 REMOVED
    Sync source_device_id                      NULL-ENFORCED
    Automatic background feed fetch             PENDING
    Full dead account/sync source cleanup       PENDING CI/dependency audit
    outbound endpoint audit                    PENDING
```

## Runtime blocker

The first real Android validation of the ARM64 validation Release proved:
- Container A restored.
- Its tab restored.
- Before process death the tab sent the configured Chrome/120 UA.
- After relaunch the restored navigation sent Gecko/Firefox 152 UA instead.
- No `Resume last tab` control was present in that post-relaunch state.

The existing restore-binding middleware/store is present in source. It is not yet runtime-proven effective. The diagnostic run `33346310470` was created against older diagnostic HEAD `c331fed0e422e01b5004a48d6b4f6400fa212689` and therefore does not prove the current privacy changes.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1

The model-independent first slice is:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor and focused CI are already proven. Do not expand AI-1 before the browser runtime milestone is closed.

## Release / APK

Manual validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Production `v*` releases remain blocked on browser runtime + release validation.

## Privacy boundary

Non-negotiable:

`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed browsing/search/feed/proxy/Tor/sharing is not automatically telemetry. App-level outbound paths must be classified as user-directed, explicitly opted-in, required for an enabled feature, or silent/unrequested.

### Completed privacy changes in this checkpoint

- About presents `WebLibre Personal Edition • Maintained by Braziao` and no longer promotes the former upstream maintainer.
- Account callback service is no longer initialized automatically.
- `WebLibre Account` and `Firefox Sync` were removed from the personal Settings UI.
- Account sign-in no longer adds Android `device_name` to the handoff query.
- Account sync repository now writes `source_device_id: null` even when legacy callers provide a device identifier.
- Personal product identity/attribution rules are documented in `WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`.
- Upstream AGPL/copyright notices remain where legally required; do not erase them merely to change branding.

### Still pending

- Remove/disable automatic `background_fetch` release startup while retaining manual feed refresh.
- Verify no other account/sync call path silently initializes the removed services.
- Audit push/background services and all outbound HTTP/WebSocket/Supabase/search/feed endpoints.
- Review broad Android permissions and `usesCleartextTraffic` against concrete feature use.
- Add an accurate local privacy/data-flow screen.

## Performance/product observations

The browser feels heavy and previously visited pages appear to risk unnecessary reloads. These are observations, not root causes. Measure startup, memory, cache/session/engine-session behavior, reloads, and APK composition before removing unrelated features.

The future UA direction is a coherent profile editor (OS, browser/version, display, locale/timezone, network/proxy and engine-supported fingerprint surfaces) with consistency constraints. Do not implement the full anti-detect feature set yet.

## Evidence rule

Never promote evidence:
`SOURCE-VERIFIED` -> `CI-VERIFIED` -> `ANDROID-RUNTIME-VERIFIED` -> `ARTIFACT-VERIFIED` -> `RELEASE-ASSET-VERIFIED`.

A successful older run does not prove a later HEAD. `[x]` is not runtime proof. A ZIP artifact is not a direct Release asset.

## Mandatory loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this map, the Workflow State, and the affected specialized document, with exact HEAD, evidence, test/run identifiers, blocker and exactly one first next step.

## Current checkpoint

**Source HEAD before this final state-save commit:** `bf374d10faced96467605f8571f28db1fc85022f`.  
**Privacy hardening:** source-changed; focused CI on the current HEAD is pending.  
**Android:** Scenario 1 FAIL on the tested validation Release; diagnostic reproduction pending.  
**First next step:** run and verify focused CI against the resulting state-save HEAD; do not build/install a new APK or modify the UA runtime fix until the privacy changes compile and their dependency boundary is known.
