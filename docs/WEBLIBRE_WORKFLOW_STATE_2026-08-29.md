# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-31  
**Branch:** `weblibre-ua-mainline-v3`  
**Current HEAD:** `7c5edd21e405cc5406a403dc8598a487bb3c68d0`

## Source of truth

GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified historical checkpoints

- Quality #39 `33329515686`: SUCCESS on the UA/container product checkpoint.
- Quality #70 `33335945926`: SUCCESS against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`; AI-1 browser-tool boundary is CI-VERIFIED.
- Manual Flutter CICD `33337359647`: SUCCESS on exact branch/head `26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`.
- Manual Flutter CICD `33341230075`: SUCCESS on exact branch/head `3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`; validation Release direct APK assets created.
- Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` is RELEASE-ASSET-VERIFIED for ARM64 and ARMv7 split APKs.
- The ARM64 runtime test from that Release produced the first causal Scenario 1 failure.
- Diagnostic Flutter CICD `33346310470` used older diagnostic HEAD `c331fed0e422e01b5004a48d6b4f6400fa212689`; it is not proof for later privacy changes.
- Manual Flutter CICD `33349437332`: SUCCESS on exact privacy/About-fix HEAD `afaf255d92fcd879905ab98bcf1dc061be6caa80`.
- Manual Flutter CICD `33350986535`: FAILED on exact privacy HEAD `492e385d31f50488dd89531bd6fcf25b2237e5f9`. The failure exposed remaining legacy Supabase/account callback dependencies.

## Browser / Android runtime

Scenario 1 remains **FAIL**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA was observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- Post-relaunch screen directly showed the restored tab; no `Resume last tab` control was present in that state.

The existing source-level restore binding uses `HistoryDelegateBindingMiddleware` + `ContainerUserAgentStore`. It is not runtime-proven effective. Dedicated diagnostic instrumentation exists for link entry, tab/context/profile identity, DB lookup result, UA assignment timing and effective setting, but the diagnostic APK came from an older HEAD.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1

Six-tool model-independent Browser Tool slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor, focused tests and CI coverage are complete. Do not expand AI-1 before browser runtime validation closes.

## Privacy / personal-product hardening

Canonical audit: `docs/WEBLIBRE_PRIVACY_DATA_FLOW_AUDIT_2026-08-31.md`.  
Canonical identity rules: `docs/WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`.

Completed source changes in the current chain:
1. About identity cleanup: `WebLibre Personal Edition • Maintained by Braziao`; former upstream promotional links removed.
2. Account callback/handoff startup path is a no-op compatibility boundary; it performs no authentication, handoff redemption, synchronization, or network operation.
3. Direct `supabase` application dependency was removed from `apps/weblibre/pubspec.yaml`.
4. Account/Firefox Sync categories are no longer exposed in the personal Settings UI.
5. Account sign-in no longer sends Android `device_name` in the handoff query.
6. Account sync no longer has a remote client: its repository is now a local disabled boundary and never transmits data.
7. Legacy account auth state no longer contains Supabase types; the auth repository is a local disabled boundary that never authenticates or persists remote sessions.
8. Legacy account callback parsing remains type-safe for existing share-intent code but performs no redemption or network operation.

Legal boundary: inherited AGPL/copyright notices remain where required. Product identity changes do not authorize false claims of upstream authorship or rewriting historical Git authorship.

## Current verification status

The current privacy/account boundary is **SOURCE-VERIFIED only**. No CI run exists yet for the current HEAD `7c5edd21...`.

## Still pending

- focused CI on current HEAD;
- remove/disable automatic `background_fetch` release startup while retaining manual feed refresh;
- prove no hidden account/sync initializer remains;
- dead account/sync source-tree cleanup after reachability is proven;
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

## Last completed step

The incomplete Supabase-removal attempt was reconciled after CI exposed all remaining compile dependencies. The legacy account auth/sync boundaries were converted to inert local compatibility implementations, and the callback parser was retained only for type safety. This checkpoint is **SOURCE-VERIFIED**.

## Current unfinished step

Focused Flutter CI has not yet been run against the current HEAD `7c5edd21e405cc5406a403dc8598a487bb3c68d0`.

## FIRST NEXT STEP — exactly one

**Run and verify focused Flutter CI on `weblibre-ua-mainline-v3` at HEAD `7c5edd21e405cc5406a403dc8598a487bb3c68d0`. Do not install an APK or resume UA runtime work until this dependency-boundary build is green.**

## Mandatory loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Every material milestone must update this state, the Master Map, and the affected specialized document with exact HEAD, evidence, run IDs, tests, blocker and one first next step.
