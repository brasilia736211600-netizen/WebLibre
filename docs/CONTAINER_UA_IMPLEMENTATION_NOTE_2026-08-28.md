# Container-scoped User-Agent implementation note — 2026-08-28

## Verified architecture
- WebLibre currently creates one `GeckoRuntime` / `GeckoEngine` for the running application.
- Each browser tab/session carries a `contextId` through the `AddTabParams` Pigeon model.
- GeckoView exposes `GeckoSessionSettings.Builder.userAgentOverride(...)` and `userAgentMode(...)` at the session level.
- Therefore a User-Agent override MUST be attached to the tab/session creation path, not to `GeckoRuntimeSettings` or the global engine.

## Required product behavior
Each cookie-isolated Container may have its own optional User-Agent configuration. The setting must be persisted with the Container metadata and applied to every tab created for that Container. Containers without an override must inherit the normal GeckoView behavior. Changing Container A must not change Container B.

## Implementation boundary
1. Add an optional UA field to `ContainerMetadata` only after the Pigeon/native creation path can consume it.
2. Extend the source Pigeon model (`AddTabParams`) with the optional UA value; regenerate generated bindings through the existing generation workflow rather than editing generated files directly.
3. In the native tab/session creation implementation, apply the UA to the `GeckoSessionSettings` for the new session before it is opened/loaded.
4. For tab duplication, explicitly carry the source Container UA policy into the new session according to the selected destination Container; do not blindly copy the source session value when a different Container is requested.
5. Add serialization and isolation tests for Container metadata before adding UI.
6. Add native/session tests that prove two sessions can receive distinct overrides and that an absent override leaves the default behavior intact.

## Important non-goals
- Do not set a global Gecko runtime preference for UA.
- Do not add a large UA profile-management abstraction before it is needed.
- Do not change Proxy routing as part of the UA patch; Proxy already has a separate per-container data path.
- Do not edit generated Pigeon/Drift files manually.

## External API verification
GeckoView 156 documentation exposes `GeckoSessionSettings.getUserAgentOverride/setUserAgentOverride` and builder `userAgentOverride`, plus `userAgentMode`. This confirms session-level customization is supported by the current GeckoView API.

## Current status
Architecture verified; implementation not yet started. Next code task is to locate the concrete native implementation of the Pigeon `addTab` operation and wire the optional UA through that path with the smallest possible patch.
