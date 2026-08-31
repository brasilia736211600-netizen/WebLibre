# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-31  
**Branch:** `weblibre-ua-mainline-v3`  
**Source HEAD before this final state-save commit:** `bf374d10faced96467605f8571f28db1fc85022f`

## Source of truth

GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified historical checkpoints

- Quality #39 `33329515686`: SUCCESS on the UA/container product checkpoint.
- Quality #70 `33335945926`: SUCCESS against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`; AI-1 browser-tool boundary is CI-VERIFIED.
- Manual Flutter CICD `33337359647`: SUCCESS on exact branch/head `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
- Manual Flutter CICD `33341230075`: SUCCESS on exact branch/head `3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`; validation Release direct APK assets created.
- Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for the ARM64 and ARMv7 split APKs.
- The ARM64 runtime test from that Release produced the first causal Scenario 1 failure.
- Diagnostic Flutter CICD `33346310470` was created against older diagnostic HEAD `c331fed0e422e01b5004a48d6b4f6400fa212689`; it must not be used as proof for the current privacy commits.

## Browser / Android runtime

Scenario 1 remains **FAIL**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA was observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- Post-relaunch screen directly showed the restored tab; no `Resume last tab` control was present in that state.

The existing source-level restore binding uses `HistoryDelegateBindingMiddleware` + `ContainerUserAgentStore`. It is not yet runtime-proven effective. The dedicated diagnostic instrumentation records link entry, tab/context/profile identity, DB lookup result, UA assignment timing and effective setting.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1

Six-tool model-independent Browser Tool slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor, focused tests and CI coverage are complete. Do not expand AI-1 before browser runtime validation closes.

## Privacy / personal-product hardening

Canonical audit: `docs/WEBLIBRE_PRIVACY_DATA_FLOW_AUDIT_2026-08-31.md`.  
Canonical identity rules: `docs/WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`.

Completed source changes:
1. About identity cleanup: `WebLibre Personal Edition • Maintained by Braziao`; former upstream promotional links removed.
2. Account callback service is no longer initialized by app startup.
3. Account and Firefox Sync categories are no longer exposed in the personal Settings UI.
4. Account sign-in no longer sends Android `device_name` in the handoff query.
5. Account sync repository now hard-enforces `source_device_id: null` at the persistence boundary.

Legal boundary: inherited AGPL/copyright notices remain where required. Product identity changes do not authorize false claims of upstream authorship or rewriting historical Git authorship.

Still pending:
- automatic `background_fetch` release startup removal/disablement;
- prove no hidden account/sync initializer remains;
- full outbound endpoint/background-service audit;
- Android permission and cleartext-traffic minimization review;
- local privacy/data-flow screen.

## Product observations

- Browser feels heavy: **unmeasured observation**.
- Previously visited pages should not be unnecessarily reloaded: **requirement/observation; root cause unproven**.
- UA UX should become a coherent profile editor rather than raw UA text: **product requirement only**.
- UA/fingerprint research is stored in `WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`; implementation remains blocked behind runtime foundation and engine-capability verification.

## Release / artifact

Direct validation Release assets are verified for the exact `3aa06cf...` build. Future production `v*` release remains blocked on Android runtime + release validation.

## Evidence levels

- `SOURCE-VERIFIED`
- `CI-VERIFIED`
- `ANDROID-RUNTIME-VERIFIED`
- `ARTIFACT-VERIFIED`
- `RELEASE-ASSET-VERIFIED`
- `DOCUMENTED`

Never promote a lower evidence level. A successful build does not prove runtime behavior. A ZIP is not a direct Release asset.

## Last completed step

Privacy hardening source pass: user-facing account/sync exposure was removed, account callback startup was disabled, account sign-in device-name transmission was removed, and sync source-device metadata is now null-enforced. Durable privacy/identity documents were updated.

## Current unfinished step

Focused CI has not yet been run against the current privacy-hardening HEAD. The older diagnostic run is not evidence for this HEAD.

## FIRST NEXT STEP — exactly one

**Run and verify focused CI against the resulting state-save HEAD; do not build/install a new APK or modify the UA runtime fix until the privacy changes compile and their dependency boundary is known.**

## Mandatory loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Every material milestone must update this state, the Master Map, and the affected specialized document with exact HEAD, evidence, run IDs, tests, blocker and one first next step.
