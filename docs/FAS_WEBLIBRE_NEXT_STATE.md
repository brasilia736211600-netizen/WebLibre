# WebLibre Next — FAS Durable Workflow State

**Last synchronized:** 2026-09-13
**Branch:** `fas-weblibre-next`
**HEAD:** `c46f67e0` (docs: define FAS autonomous WebLibre Next build)
**Source checkpoint:** `32f9e2d98df30dc24cf64414de6f17d077570b8d`

## Source of truth
GitHub refs, commits, CI runs, artifacts and release assets are authoritative.

## Baseline (verbatim from docs/FAS_WEBLIBRE_NEXT_BUILD.md)
- Base source: `FaFre/WebLibre` (AGPL-3.0).
- Execution line: branch `fas-weblibre-next`, intentionally separate from `main` and the draft UA PR branches.
- Starting source checkpoint: `32f9e2d9`.

## Phase 0 reconcile — completed
- Read master map, workflow state, AI agent spec, operating rules and the FAS build file.
- Verified branch/HEAD: `fas-weblibre-next` @ `c46f67e0`; the only commit above the checkpoint is the FAS build doc.
- Open PRs: #3 (feat containers UA, DRAFT, base `main`, branch `weblibre-ua-mainline-v3`), #2 (DRAFT), #1 (CLOSED).
- No CI runs exist yet on `fas-weblibre-next`; the Validation APK workflow only triggered on `weblibre-ua-mainline-v3`.
- Uncommitted local work (preserved, not committed): profile-scoped sing-box proxy credentials, sing-box runtime stop on exit.

## CI truth at checkpoint 32f9e2d9 (from last `weblibre-ua-mainline-v3` runs)
- WebLibre Quality: **SUCCESS** at UA PR #3 head `8a407ea` (run 33998780934) — AI-1 tool tests, container tests and native build green.
- WebLibre Validation APK:
  - Build stable split APKs (arm64-v8a; ABI split, ~151.5 MB release) — PASS.
  - Deterministic sha256 integrity checks — PASS (checkpoint commit `32f9e2d9`).
  - API-35 emulator smoke — **FAIL**.
- Emulator failure root cause: `avdmanager create avd --device Pixel_2` fails with `Error: No device found matching --device Pixel_2.` The SDK tooling no longer ships the `Pixel_2` hardware profile. Runner also reports no KVM, so emulation is software (`-accel` disabled by the action).

## Current slice — Validation APK gate on this branch
Fix applied (uncommitted): `docs/.../.github/workflows/validation-apk.yml`
- Added `fas-weblibre-next` to push triggers.
- Added a "Prepare emulator system image and AVD" step that creates `weblibre-test` AVD WITHOUT a `--device` hardware profile dependency.
- Emulator step now reuses that AVD (`avd-name: weblibre-test`, `force-avd-creation: false`) and removed the `Pixel_2` profile.
- Hardened `launch_and_verify` to poll for a resumed activity (up to 120s first launch, 60s relaunch) instead of fixed sleeps, to tolerate software-emulation latency; crash-buffer check retained.

## Verification levels (evidence ladder)
`SOURCE-VERIFIED -> TEST-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-READY`
No claim beyond the currently established level is made.

## Blockers
1. Validation APK emulator smoke has never run green (AVD profile failure). Repaired; awaiting a run on this branch.
2. Android Scenario 1 (persisted per-container UA across relaunch) needs fresh Android-runtime evidence after the CI gate is green.

## FIRST NEXT STEP — exactly one
Push the scoped validation-apk fix, retrieve the triggered exact-head run, and verify its emulator smoke + APK artifact results.