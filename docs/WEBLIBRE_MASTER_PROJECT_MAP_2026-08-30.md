# WebLibre — Master Project Map

**Canonical source of truth:** GitHub repository, refs, commits, PRs, CI/build/release runs, artifacts and release assets.
**Branch:** `weblibre-ua-mainline-v3`
**Current source HEAD:** `b958b5eb5549ae47c4249d729b4575c7f643bdbb`

## Durable documents

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
    About identity cleanup                      SOURCE-VERIFIED
    Account callback startup                   DISABLED
    Account/Firefox Sync Settings UI           REMOVED
    Account sign-in device_name                 REMOVED
    Sync source_device_id                      NULL-ENFORCED
    Direct Supabase application dependency     REMOVED
    Account auth/sync boundary                 SOURCE-VERIFIED
    Search credits remote boundary             SOURCE-VERIFIED
    Subscription remote boundary               SOURCE-VERIFIED
    Account Settings legacy dependency graph    SOURCE-VERIFIED reduced
    Automatic background feed fetch             PENDING
    Full dead account/sync source cleanup       PENDING CI/reachability audit
    outbound endpoint audit                    PENDING
```

## Runtime blocker

The first real Android validation of the ARM64 validation Release proved:
- Container A restored.
- Its tab restored.
- Before process death the tab sent the configured Chrome/120 UA.
- After relaunch the restored navigation sent Gecko/Firefox 152 UA instead.
- No `Resume last tab` control was present in that post-relaunch state.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1

The model-independent first slice is:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor, focused tests and CI coverage are already proven. Do not expand AI-1 before the browser runtime milestone is closed.

## Release / APK

Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Production `v*` releases remain blocked on browser runtime + release validation.

## Privacy boundary

Non-negotiable:

`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

User-directed browsing/search/feed/proxy/Tor/sharing is not automatically telemetry. App-level outbound paths must be classified as user-directed, explicitly opted-in, required for an enabled feature, or silent/unrequested.

### Source changes verified in this checkpoint

- About identity cleanup remains in place.
- Account callback/handoff startup is a no-op compatibility boundary.
- Direct `supabase` application dependency is removed.
- Account/Firefox Sync categories are no longer exposed in personal Settings.
- Account sign-in no longer sends Android `device_name`.
- Account sync repository is a local disabled boundary and never transmits data.
- Legacy auth state/repository is a local disabled boundary.
- Search credits repository is now a local zero-credit boundary; it no longer invokes remote RPC.
- Subscription repository is now a local inactive boundary; it no longer invokes remote RPC.
- Search token issuance is disabled at the compatibility boundary; it no longer obtains an account access token or calls remote issuance.
- Account Settings was reduced to a local compatibility screen and no longer references subscription/search-credit/sync UI dependencies.
- Share-intent account callback parsing remains type-correct but does not redeem or upload a callback.
- Required upstream AGPL/copyright notices remain; product branding is not a license to erase legal attribution.

## CI evidence

`33353864553 / job 99502870834` failed on exact source HEAD `e3f2086fa349afe2858e83bda53de30ce5ae8f11` during Flutter compilation. The concrete failures were remaining `auth`/`rpc`/Riverpod notifier/account-callback references. Native Go runtime and browser component build succeeded.

The current source fixes above are **SOURCE-VERIFIED only**. They have not yet been CI-verified.

## Performance/product observations

Browser heaviness and unnecessary reloads are observations, not proven root causes. Measure startup, memory, cache/session/engine-session behavior and APK composition before removing unrelated features.

Future UA direction is a coherent profile editor (OS, browser/version, display, locale/timezone, network/proxy and engine-supported fingerprint surfaces) with consistency constraints. Do not implement the full anti-detect feature set before the runtime foundation is stable.

## Evidence rule

Never promote:
`SOURCE-VERIFIED` -> `CI-VERIFIED` -> `ANDROID-RUNTIME-VERIFIED` -> `ARTIFACT-VERIFIED` -> `RELEASE-ASSET-VERIFIED`.

A successful older run does not prove a later HEAD. `[x]` is not runtime proof. A ZIP artifact is not a direct Release asset.

## Mandatory loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this map, the Workflow State, and the affected specialized document with exact HEAD, evidence, tests/run IDs, blocker and exactly one first next step.

## Current checkpoint

**Current source HEAD:** `b958b5eb5549ae47c4249d729b4575c7f643bdbb`.
**Last CI:** `33353864553 / 99502870834` failed on prior HEAD `e3f2086...`.
**Current privacy/account boundary:** SOURCE-VERIFIED, CI PENDING.
**Android:** Scenario 1 FAIL; UA restore remains runtime blocker.
**First next step:** run and verify Flutter CI against current HEAD; do not install an APK or resume UA runtime work until the current privacy/account dependency boundary is green.
