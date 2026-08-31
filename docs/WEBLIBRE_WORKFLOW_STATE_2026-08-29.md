# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `feee97f2e9c696429e59b2c055ed7633ff3dcc9c`

## Source of truth

GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified historical checkpoints

- Quality #39 `33329515686`: SUCCESS on the UA/container product checkpoint.
- Quality #70 `33335945926`: SUCCESS against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`; AI-1 browser-tool boundary is CI-VERIFIED.
- Manual Flutter CICD `33337359647`: SUCCESS on exact branch/head `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
- Manual Flutter CICD `33341230075`: SUCCESS on exact branch/head `3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`; validation Release direct APK assets created.
- Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for ARM64 and ARMv7 split APKs.
- ARM64 runtime test from that Release produced the first causal Scenario 1 failure.
- Diagnostic Flutter CICD `33346310470`: older diagnostic HEAD `c331fed0e422e01b5004a48d6b4f6400fa212689`; not proof for later changes.
- Manual Flutter CICD `33349437332`: SUCCESS on exact HEAD `afaf255d92fcd879905ab98bcf1dc061be6caa80`.
- Manual Flutter CICD `33350986535`: FAILED on exact HEAD `492e385d31f50488dd89531bd6fcf25b2237e5f9`; exposed remaining legacy Supabase/account dependencies.
- Manual Flutter CICD `33353864553 / 99502870834`: FAILED on exact HEAD `e3f2086fa349afe2858e83bda53de30ce5ae8f11`; exposed remaining `auth`, `rpc`, Riverpod notifier, and account-callback compile references. Native Go runtime and browser components succeeded.

## Browser / Android runtime

Scenario 1 remains **FAIL**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1

Six-tool model-independent Browser Tool slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor, focused tests and CI coverage are complete. Do not expand AI-1 before browser runtime validation closes.

## Privacy / personal-product hardening

Canonical audit: `docs/WEBLIBRE_PRIVACY_DATA_FLOW_AUDIT_2026-08-31.md`.
Canonical identity rules: `docs/WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`.

### Current source-verified boundary

1. About identity cleanup remains in place.
2. Account callback/handoff startup is a no-op compatibility boundary.
3. Direct `supabase` application dependency is removed.
4. Account/Firefox Sync categories are no longer exposed in personal Settings.
5. Account sign-in no longer sends Android `device_name`.
6. Account sync repository is a local disabled boundary and never transmits data.
7. Legacy account auth state/repository is a local disabled boundary.
8. Search credits repository is a local zero-credit boundary and no longer invokes remote RPC.
9. Subscription repository is a local inactive boundary and no longer invokes remote RPC.
10. Search token issuance is disabled and no longer obtains an account access token or calls remote issuance.
11. Account Settings no longer imports subscription/search-credit/sync UI dependencies.
12. Share-intent callback parsing is type-correct; callback redemption/upload remains disabled.
13. Required upstream AGPL/copyright notices remain. Product identity changes do not erase legal attribution or historical Git authorship.

### Current verification

The privacy/account dependency cleanup at `b958b5eb5549ae47c4249d729b4575c7f643bdbb` is **SOURCE-VERIFIED only**. The map/state documentation was then updated in commit `feee97f2e9c696429e59b2c055ed7633ff3dcc9c`; the current HEAD is therefore `feee97f2...` and must be the next CI target.

## Still pending

- CI verification of current HEAD `feee97f2...`.
- Remove/disable automatic `background_fetch` release startup while retaining manual feed refresh.
- Prove no hidden account/sync initializer remains.
- Remove dead account/sync source files only after dependency reachability is proven.
- Full outbound endpoint/background-service audit.
- Android permission and cleartext-traffic minimization review.
- Local privacy/data-flow screen.
- UA runtime Scenario 1 root-cause fix and Android revalidation.

## Product observations

- Browser feels heavy: unmeasured observation.
- Previously visited pages should not be unnecessarily reloaded: requirement/observation; root cause unproven.
- UA UX should become a coherent profile editor rather than raw UA text: product requirement only.
- UA/fingerprint research is stored in `WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`; implementation remains behind runtime foundation and engine-capability verification.

## Release / artifact

Direct validation Release assets are verified for exact `3aa06cf...` build. Production `v*` release remains blocked on Android runtime + release validation.

## Last completed step

Account/Supabase dependency closure was corrected against the concrete CI errors: search credits and subscription remote RPC paths were converted to local disabled boundaries; token issuance was disabled; Account Settings was reduced to a local compatibility screen; share-intent callback parsing was made type-correct. Documentation was synchronized afterward. This is **SOURCE-VERIFIED**, not CI-VERIFIED.

## Current unfinished step

Current HEAD `feee97f2e9c696429e59b2c055ed7633ff3dcc9c` has not yet passed Flutter CI.

## FIRST NEXT STEP — exactly one

**Run and verify Flutter CI on `weblibre-ua-mainline-v3` at HEAD `feee97f2e9c696429e59b2c055ed7633ff3dcc9c`. Do not install an APK or resume UA runtime work until this build is green.**

## Mandatory loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Every material milestone must update this state, the Master Map, and the affected specialized document with exact HEAD, evidence, tests/run IDs, blocker and one first next step.
