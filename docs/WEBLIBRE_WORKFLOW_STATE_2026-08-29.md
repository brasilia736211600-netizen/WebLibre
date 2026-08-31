# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-01
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD:** `eea4b40baef357136d38e057f708106aeb112da0`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified current checkpoint
- PR #3 is OPEN and DRAFT, base `main`, current `head_sha` `eea4b40baef357136d38e057f708106aeb112da0`.
- Current branch ref `weblibre-ua-mainline-v3` points to the same `eea4b40...` HEAD.
- Flutter CICD `33420348298`, job `99580917046`: SUCCESS on exact `eea4b40...`.
- Stable APK build succeeded; native gomobile runtime build succeeded; validation-release creation step succeeded.
- Quality #60 `33334955774` is SUCCESS but is on older `477140419642d1170b241dd39f143900b9b98909` and predates the AI-1 test-step addition, so it is not current AI-1 CI proof.
- The Quality workflow on the current branch contains the AI-1 registry/executor tests and targeted container/native tests, but a current run for `eea4b40...` has not been verified.

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

Contracts, registry, executor, source mappings and focused tests are implemented and SOURCE-VERIFIED. Current Quality CI verification remains pending.

## Privacy / personal-product hardening
The source boundary is SOURCE-VERIFIED and now has successful Flutter build verification on exact checkpoint `eea4b40...`. This does not prove Android runtime behavior or current Quality test execution.

Confirmed source changes include:
1. About identity cleanup.
2. Account callback/handoff startup disabled as a no-op compatibility boundary.
3. Direct application Supabase dependency removed.
4. Account/Firefox Sync categories removed from personal Settings.
5. Account sign-in no longer sends Android `device_name`.
6. Account sync writes `source_device_id: null`.
7. Legacy auth/sync paths are disabled/local boundaries.
8. Search credits remote RPC path replaced by local zero-credit boundary.
9. Subscription remote RPC path replaced by local inactive boundary.
10. Search token issuance disabled.
11. Account Settings reduced to local compatibility UI.
12. Share-intent callback parsing remains type-correct while redemption/upload remains disabled.
13. Required upstream AGPL/copyright notices remain.

Still pending: automatic background feed fetch removal, dead-source/reachability audit, outbound endpoint/background-service audit, permission/cleartext minimization review, local privacy/data-flow screen, and Android UA Scenario 1 root-cause fix/revalidation.

## Release / artifact evidence
Validation Release `validation-stable-5-3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5` remains RELEASE-ASSET-VERIFIED for the independently published ARM64 and ARMv7 APK assets. This is historical evidence for that exact release/checkpoint and is not evidence for a later HEAD.

## Last completed step
**Flutter CI/build verification of the current privacy/account source checkpoint completed successfully:** run `33420348298`, job `99580917046`, exact head `eea4b40baef357136d38e057f708106aeb112da0`.

## Current unfinished step
**AI-1/current Quality CI verification remains incomplete:** no verified Quality run currently matches `eea4b40baef357136d38e057f708106aeb112da0`.

## FIRST NEXT STEP — exactly one
**Run and verify the Quality workflow on `weblibre-ua-mainline-v3` at the exact current HEAD `eea4b40baef357136d38e057f708106aeb112da0`; require SUCCESS for the AI-1 registry/executor tests and targeted container/native tests before proceeding to any Android installation/runtime work.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this state, the Master Map, and the affected specialized document with exact HEAD, evidence, tests/run IDs, blocker and one first next step.
