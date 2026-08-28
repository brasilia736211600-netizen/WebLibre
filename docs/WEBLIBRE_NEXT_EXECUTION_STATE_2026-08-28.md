# WebLibre — Next Execution State — 2026-08-28

## Verified checkpoint
- Primary branch: `weblibre-p0-container-restore`
- Latest green P0 validation commit: `ef2809b51a7377bdb64a99e08fc75139a86deb93`
- P0 Validation Run #19: `33169579083` — SUCCESS
- Debug APK compiled and uploaded as `weblibre-p0-debug-apk`
- Physical APK installation/runtime verification is intentionally deferred due to limited mobile bandwidth.

## Current source-level boundary
`TabRepository.addTab()` resolves the selected/site-assigned container before creating the Gecko tab. The resulting `contextId` is derived from the container's `metadata.contextualIdentity` (except isolated tabs), and `excludeFromHistory` is also passed into the engine before the tab starts loading.

This is the correct existing boundary for future Container Identity V1 work. Do not introduce a parallel per-tab identity manager.

## Proxy status
`ContainerMetadata` already stores:
- `proxyConnectionId`
- `bypassGlobalProxy`

`sanitized()` normalizes proxy state away when `contextualIdentity` is absent. Existing proxy commits cover routing, UI, isolation, autostart, and port-collision hardening. Treat Proxy as existing/partial and audit/harden it rather than rebuilding it.

## User-Agent status
No proven Container-scoped UA implementation has been established yet. Do not add a storage field or UI control until the native Gecko/session capability and the session creation/reuse path are located and proven.

## Immediate execution order
1. Keep physical APK verification deferred.
2. Continue source-level P0 restore/reconciliation tests and proofs.
3. Keep screenshot/context-menu black-screen isolated as P1.
4. Audit Container Identity V1 boundary at tab/session creation.
5. Implement UA only through the existing Gecko capability and the Container identity boundary.
6. Harden Proxy at the same Container boundary, preserving independent configuration per Container and preventing leakage.
7. Build the feature-gap matrix before adding remaining P3 features.

## Non-negotiable rules
- Never revive `_freshSnapshotPending` or first-event heuristics.
- Destructive DB reconciliation requires authoritative correlated data.
- No direct edits to generated Pigeon/Drift files.
- No broad dependency upgrades during focused work.
- Prefer the smallest invariant-preserving patch.
- Do not claim physical-device behavior is verified until the APK has actually been tested on-device.
