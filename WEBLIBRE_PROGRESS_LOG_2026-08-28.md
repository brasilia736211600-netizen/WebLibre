# WebLibre Progress Log — 2026-08-28

## Current verified state
- Primary work branch: `weblibre-p0-container-restore`
- Latest verified P0 commit: `ef2809b51a7377bdb64a99e08fc75139a86deb93`
- P0 Validation Temp Run #19: `33169579083` — SUCCESS
- Debug APK compile: SUCCESS
- Debug APK artifact: `weblibre-p0-debug-apk`
- Artifact SHA-256: `b3e278d43e752b7f0a4bfdd1f5c633324d8ca4e08d47d3753dde2800efa2829d`
- APK artifact download is intentionally deferred for the user because of limited mobile bandwidth.

## What is now proven by CI
- Pigeon `getCurrentTabIds` bridge present across Dart/generated Kotlin/native implementation.
- Flutter analyze completed successfully on the latest green run.
- External assets update passed.
- Components build passed.
- Targeted TabRepository test passed.
- Pinned native runtime checkout passed.
- Combined gomobile runtime build passed.
- AAR verification passed.
- Debug APK compilation passed.
- Debug APK artifact upload passed.

## Important interpretation
Build Gate is closed: compilation/package generation is proven on CI. Runtime behavior on a physical Android device is NOT yet proven and remains deferred until bandwidth permits.

## Immediate project direction
Do not spend further time on APK build debugging unless a new regression appears. Continue source-level and CI-verifiable work while physical-device APK download is deferred.

Priority order:
1. P0 data integrity / restore verification via source-level tests and proofs.
2. P1 screenshot/context-menu black-screen lifecycle investigation.
3. P2 startup/navigation/restore behavior.
4. P3 Container Identity and agreed per-container customization.
5. Remaining agreed feature-gap work.
6. P4 UX.
7. P5 performance/architecture.

## Per-container requirements
Each container must have independent, configurable settings:
- User-Agent: scoped to that container, configurable from that container's settings.
- Proxy: scoped to that container, configurable from that container's settings.
- No leakage/collision across containers.

Current evidence:
- `ContainerMetadata` already contains `proxyConnectionId` and `bypassGlobalProxy` and sanitizes proxy state based on `contextualIdentity`.
- User-Agent is not yet proven implemented as a container-scoped feature. Audit the native Gecko/session capability before adding storage or UI.

## Engineering rules
- Audit -> plan -> implement -> test -> verify -> checkpoint -> next.
- YAGNI: reuse existing capability; smallest invariant-preserving patch.
- No broad dependency upgrades during focused debugging.
- No direct edits to generated Pigeon/Drift files.
- No destructive DB writes based on uncorrelated event arrival.
- Never revive `_freshSnapshotPending` or any first-event heuristic without real request/generation provenance.
- Keep screenshot/black-screen work separate from restore work unless evidence establishes a dependency.

## Known CI/workflow lesson
The P0 workflow must checkout the exact triggering SHA (`ref: ${{ github.sha }}`) rather than a hard-coded branch. Analyzer findings are currently non-fatal where they are informational/warnings, but actual build/test failures must remain fatal.

## Human queue
- Physical-device acceptance for container/session restore matrix.
- Physical-device reproduction and verification of screenshot/black-screen bug.
- Product decisions only where repository/spec/history cannot determine intended behavior.

## Resume rule
On a future chat: read this file and `WEBLIBRE_MASTER_HANDOFF_2026-08-28.md`, then verify live GitHub state before making claims about status.
