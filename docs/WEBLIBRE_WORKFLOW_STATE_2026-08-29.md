# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD at this state-save:** `1e4d0fad28e7d675036fc3db91995f8f528d0e6c`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts, and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified checkpoints
- Quality #39 `33329515686`: SUCCESS on UA/container product checkpoint.
- Quality #70 `33335945926`: SUCCESS against `f05f643eda7ffb6503a4d6429b24e0d77ce7ad0d`; AI-1 browser tool tests, targeted container tests, native gomobile build, and targeted native container tests passed. AI-1 execution boundary is CI-VERIFIED.
- Manual Flutter CICD `33337359647`: SUCCESS on exact branch `weblibre-ua-mainline-v3` and exact `head_sha=26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`; stable APK build and ZIP artifact upload passed.
- Artifact `9739745969`: `weblibre-stable-apk-26e96cfc5a13b952ee0f4af31689fb927dbdfd9d`; SHA-256 `95e399057371d143e08784330280fb8b5106ffb4ec5dd06c35fe952d9703329f`; contains both split APKs.

## Browser/runtime state
Browser/UA implementation is source-verified and existing focused CI is green. Real Android runtime proof remains pending for:
1. cold-start/restored-tab UA persistence;
2. Container A/B UA isolation across open, duplicate, and restore;
3. restore isolation;
4. Proxy A/B isolation;
5. proxy fail-closed;
6. no cross-container mutation.

No dedicated Android integration harness exists. Checklist: `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`.

## AI-1 state
Six-tool model-independent Browser Tool boundary:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.
Contracts, registry, executor, focused tests, and CI coverage are complete. Do not expand AI-1 unless evidence proves insufficiency.

## Manual APK / Release distribution
The existing build workflow has `workflow_dispatch` for `stable`, `alpha`, and `alphaLegacy` validation builds. Validation builds upload APK artifacts without publishing to Google Play.

A direct GitHub prerelease asset path has been implemented in the workflow. Validation runs are intended to publish these individual assets:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Future production/stable releases must continue using the existing `v*` path and publish both split-ABI APKs plus the AAB only after Android runtime and release validation are complete.

Previous manual stable build `33337359647` predates this direct-asset workflow change, so its ZIP artifact does not prove direct Release assets.

## CI/build/release evidence gate
For every build/release milestone, do not mark the step complete until this chain is verified:
`intended change -> commit SHA -> workflow revision contains change -> run branch/ref -> run.head_sha == intended SHA -> required job SUCCESS -> required step SUCCESS (not SKIPPED) -> expected artifact/release exists -> expected asset names/URLs/checksum verified`.

A successful older run cannot prove a later workflow change. An artifact ZIP is not equivalent to individual GitHub Release assets.

## Last completed step
AI-1 execution boundary is CI-VERIFIED. The integrated stable APK artifact was successfully built for `26e96cfc...`. The durable resume protocol was strengthened with explicit CI/build/release/artifact correlation rules.

## Current unfinished step
Fresh manual `stable` Flutter CICD verification of the direct GitHub validation Release assets:
- stable APK build succeeds;
- validation Release is created;
- both split-ABI APKs are attached directly;
- exact asset names/URLs are verified;
- run `head_sha` matches the built commit.

After this, real Android runtime proof remains pending.

## Exact next execution
1. Run `Flutter CICD` manually on `weblibre-ua-mainline-v3` with `stable` using the workflow revision that contains the direct Release-asset path.
2. Verify run `head_sha` and that Release creation/upload steps are SUCCESS, not SKIPPED.
3. Verify the prerelease contains both individual APK assets by exact filename and direct URL.
4. Use the ARM64 Release asset for the consolidated Android runtime checklist; do not rebuild per scenario.
5. If runtime fails, preserve the first causal evidence and inspect the existing call chain before any architecture change.
6. Only after Android runtime verification, complete release validation and continue to AI-2 Agent Core.

## Resume / anti-amnesia
Canonical resume: `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`.
Evidence levels: `SOURCE-VERIFIED`, `CI-VERIFIED`, `ANDROID-RUNTIME-VERIFIED`, `ARTIFACT-VERIFIED`, `RELEASE-ASSET-VERIFIED`, `DOCUMENTED`.
At every material milestone update both Master Map and Workflow State with exact HEAD, CI/build/release identifiers, test evidence, blockers, and one first next step.

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
