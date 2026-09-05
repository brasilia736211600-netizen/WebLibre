# WebLibre — Project Handoff / Master Continuation Map

**Date:** 2026-08-28
**Purpose:** Durable handoff for continuing the WebLibre fork with another AI agent or a future session.

## 1. Project identity

- User fork: `brasilia736211600-netizen/WebLibre`
- Upstream referenced during the project: `FaFre/WebLibre`
- Primary working environment: Android phone, Acode + Acode Terminal/Termux.
- The user wants the project completed on the existing WebLibre codebase, not rebuilt from scratch.
- Internet/bandwidth is limited, so avoid unnecessary large APK downloads and expensive full builds until targeted checks pass.

## 2. Core product goal

Turn the WebLibre fork into a privacy-oriented browser in which container-specific privacy/network identity can be configured independently.

The major agreed feature direction includes:

1. Independent proxy per container.
2. Independent User-Agent per container.
3. Per-container settings UI for these properties.
4. Persistence/restoration of container configuration.
5. Correct isolation: Container A's UA/proxy must not silently affect Container B.
6. Preserve existing WebLibre architecture and avoid invasive upstream forks where unnecessary.

## 3. Current architecture facts

The repository is a Flutter/Dart workspace with local packages, including:

- `apps/weblibre/`
- `packages/flutter_mozilla_components/`
- `packages/flutter_tor/`
- `packages/flutter_singbox_proxy/`
- `packages/locale_resolver/`
- `packages/simple_intent_receiver/`
- `packages/speech_to_text_dialog/`

`flutter_mozilla_components` is a local package with Android/Kotlin code. It uses Android Components / GeckoView rather than implementing Gecko itself.

The relevant dependency line was verified as Android Components `152.0.4`, including `browser-engine-gecko`, `concept-engine`, and `feature-session`.

`EngineProvider` creates `GeckoEngine` and installs local Features including the container proxy feature.

## 4. Work completed — data model

### User-Agent

`ContainerMetadata` now has:

```dart
String? userAgent
```

The property is integrated with the model's:

- JSON serialization/deserialization.
- `copyWith`.
- equality semantics.
- blank/whitespace normalization behavior.

The generated Dart serialization was synchronized.

Tests were added for:

- custom UA JSON round-trip;
- blank UA becoming `null`;
- distinct UA values remaining distinct;
- `copyWith(userAgent: ...)`.

This is the completed data-contract slice. It is NOT yet the complete runtime feature.

## 5. Work completed — proxy direction

Per-container proxy is an established project requirement and has already been part of the existing WebLibre work. The project uses container-specific proxy state rather than a single global proxy policy.

Important constraint:

> Do not collapse proxy configuration into a global runtime setting.

The target architecture is one independent proxy configuration per container, configurable from that container's settings.

## 6. Critical forensic finding — container restore / tab events

A separate forensic investigation was performed around container/session restoration and Gecko tab-list events.

Important conclusion:

`syncEvents()` returns `Future<void>` and does not return a request token. Tab-list events contain a sequence number, but the current API does not provide request/generation provenance that mathematically proves a particular tab-list event was caused by a particular `syncEvents()` call.

Why naive correlation is UNSOUND:

- stale debounced tab-list events may already be queued;
- RPC and GeckoStateEvents use separate channels;
- current tab-list payloads have no request/generation ID;
- awaiting `syncEvents()` does not prove the next event is the response to that request.

The previously proposed `_freshSnapshotPending` approach was explicitly rejected as unsound.

Potential future API-level solution discussed:

- extend `syncEvents()` to return a sequence/generation boundary or request ID;
- regenerate Pigeon code after such an API change.

Do not resurrect `_freshSnapshotPending` as if it were a reliable correlation mechanism.

## 7. Critical UA runtime finding

The correct runtime target is **GeckoSession / EngineSession**, not the global GeckoRuntime.

Android Components exposes a session-level settings path. The investigated `GeckoEngineSession` creates GeckoSession settings before opening the session, and GeckoView supports a session-specific User-Agent override.

Therefore the desired invariant is:

```text
ContainerMetadata.userAgent
        -> tab/session creation
        -> EngineSession settings
        -> GeckoSession userAgent override
        -> first navigation
```

Do NOT implement UA as a global runtime setting.

## 8. Exact native integration point discovered

Local `GeckoTabsApiImpl` is the critical native integration point.

Current conceptual flow:

```text
addTab()
  -> create TabSessionState
  -> AddTabAction
  -> LoadUrlAction
```

Android Components also supports creating a tab with an already-created `engineSession`.

Therefore the safest runtime ordering is:

```text
create EngineSession
  -> set session userAgentString / override
  -> create TabSessionState with that session
  -> AddTabAction
  -> LoadUrlAction
```

This avoids the race where a page begins loading before the custom UA is installed.

## 9. Native implementation still pending

The following are NOT yet completed and must not be reported as completed:

- passing `userAgent` through the actual AddTab contract;
- applying UA to the native EngineSession;
- handling multi-tab creation with per-container UA;
- handling duplicate-tab creation with correct UA;
- restore/recovery behavior where UA must be applied before the first restored navigation;
- runtime isolation test proving Container A and B can have different UAs simultaneously;
- container settings UI for UA.

## 10. Recommended UA implementation sequence

Implement as a small vertical slice:

1. Add `userAgent` to the tab creation contract (`AddTabParams` / relevant Pigeon API source).
2. Regenerate Pigeon Dart/Kotlin output using the project's official generation task.
3. Propagate the value from the Dart tab/container layer.
4. In `GeckoTabsApiImpl`, create the EngineSession first.
5. Apply the custom UA to that session.
6. Construct the tab state with the prepared session.
7. Only then dispatch the first URL load.
8. Cover `addTab`, `addMultipleTabs`, and `duplicateTab`.
9. Handle restore separately and explicitly.
10. Add a runtime test proving two containers can have different UAs.
11. Only after runtime behavior is correct, add/finish the UI.

Do not manually edit generated Pigeon output unless generation is impossible and the reason is documented.

## 11. Branch / PR state at handoff

A clean feature branch was created from the latest mainline for the UA work:

`weblibre-ua-mainline-v2`

A Draft PR was opened as PR #2 for the initial UA data-contract slice.

The branch was intentionally kept separate from `main` while the native work was being investigated.

The initial UA slice was approximately:

- `container_data.dart`
- generated serialization file
- `container_data_test.dart`

Do not merge PR #2 merely because the data model passes; native runtime behavior is still incomplete.

## 12. Git safety rules

- NEVER use `main` as a scratch branch.
- Work on a dedicated feature branch.
- Before modifying an existing file, fetch its current blob/contents and use the current SHA.
- Prefer atomic, reviewable commits.
- Do not create temporary files on `main`.
- Do not overwrite large Pigeon/generated files from partial snippets.
- After every significant change, compare the feature branch against `main`.
- If an operation produces unexpected unrelated deletions, stop and restore before continuing.

## 13. CI/build history

A previous Flutter debug workflow reached Gradle after Rust builds but failed after a long build (~756 seconds) with:

`Gradle build failed to produce an .apk file. It's likely that this file was generated under /home/runner/work/WebLibre/WebLibre/apps/weblibre/build, but the tool couldn't find it.`

This means a full APK build is expensive and has previously failed at artifact discovery rather than proving the Dart/native code was invalid.

Recommended order:

```text
Dart/unit tests
-> analyze
-> targeted Kotlin/native checks
-> Pigeon generation check
-> targeted integration/build
-> full APK build only at a stable milestone
```

## 14. Tool/environment context

The user primarily works from an Android phone using Acode + Acode Terminal/Termux.

Previously used versions/commands include:

- Node.js 22.23.2
- npm 10.9.1
- Git 2.47.3
- Flutter stable 3.47.0 in CI
- `flutter build apk --debug --no-tree-shake-icons`
- `npm run typecheck`
- `npm test`
- `npm run build`

The Acode AI Agent repository was also investigated separately at `/public/acode-ai-agent/acode-ai-agent`. That is an AI tooling project, not the WebLibre application itself.

## 15. Acode AI Agent / provider context

The user wanted an AI coding agent integrated with Acode and considered OpenRouter and alternatives.

OpenRouter free-model rate limits were encountered, including HTTP 429/free-models-per-minute limits and upstream temporary rate limiting.

Do not confuse this AI-agent work with the WebLibre runtime implementation.

## 16. Full feature roadmap

### Phase A — foundation

- [x] Preserve existing WebLibre architecture.
- [x] Container metadata supports custom UA.
- [x] Persist UA.
- [x] Test UA model behavior.
- [x] Preserve per-container proxy concept.

### Phase B — UA runtime

- [ ] Pass UA into tab/session creation.
- [ ] Apply UA before first navigation.
- [ ] Support multiple-tab creation.
- [ ] Support duplicate tab.
- [ ] Correct restore/recovery.
- [ ] Runtime A/B isolation test.

### Phase C — container settings UI

- [ ] Add UA field to each container's settings.
- [ ] Add proxy configuration to each container's settings if not already exposed completely.
- [ ] Clear/reset-to-default behavior.
- [ ] Validation and normalization.
- [ ] Ensure edits affect only the selected container.

### Phase D — proxy hardening

- [ ] Verify proxy is applied before navigation for new sessions.
- [ ] Verify proxy lifecycle during restore.
- [ ] Verify two containers can use different proxies concurrently.
- [ ] Verify changing Container A never changes Container B.
- [ ] Add targeted regression tests.

### Phase E — restore/session correctness

- [ ] Revisit `syncEvents` correlation problem.
- [ ] If reliable freshness is required, introduce explicit sequence/generation provenance.
- [ ] Regenerate Pigeon after any API change.
- [ ] Add concurrency regression tests.

### Phase F — quality / release

- [ ] `flutter analyze` clean.
- [ ] Dart tests clean.
- [ ] Kotlin/native tests clean.
- [ ] Pigeon generation reproducible.
- [ ] CI green.
- [ ] Debug APK artifact correctly located/uploaded.
- [ ] Release build only after debug milestone is stable.

## 17. Non-negotiable architectural invariants

1. UA is per container/session, never global.
2. Proxy is per container, never silently global.
3. A container's settings must not mutate another container.
4. UA must be applied before first navigation.
5. Restore must not accidentally lose the container's UA/proxy policy.
6. Do not rely on event-arrival heuristics as proof of request/response correlation.
7. Avoid modifying Android Components upstream when a local WebLibre integration can solve the requirement.
8. Keep generated files synchronized with their source generator.
9. Prefer targeted tests before expensive APK builds.
10. Never claim a feature is complete until both persistence and runtime behavior are verified.

## 18. Immediate next actions

1. Inspect the exact current `AddTabParams` / Pigeon source on the feature branch.
2. Add `userAgent` to the source contract.
3. Run the project's Pigeon generation command.
4. Update the Dart caller that already knows the assigned container.
5. Update `GeckoTabsApiImpl` to prepare the EngineSession with the container UA before the first load.
6. Add tests for two simultaneous containers with different UA values.
7. Implement restore handling.
8. Add the per-container settings UI.
9. Harden/test proxy isolation.
10. Only then run a full APK build.

## 19. Handoff rule for another AI agent

The next agent must first read this document, inspect the actual current branch/HEAD, compare it with `main`, and only then modify code.

The next agent must NOT assume that any item marked `[ ]` is implemented merely because a related data field exists.

The next agent must preserve the current WebLibre repository and must not rewrite it from scratch.

If a separate fork is requested, fork the user's current repository into a NEW repository owned/controlled by the user or the agent's workspace, and perform all experimental changes only in that fork. Do not push experimental commits to the current production/reference repository.

## 20. Current status summary

**Data foundation:** substantially complete.

**Per-container UA runtime:** designed and integration point identified, but not yet completed.

**Per-container proxy:** architectural requirement established; continue hardening and verify runtime isolation.

**Per-container settings UI:** pending.

**Restore/session forensic issue:** analyzed; reliable request/event correlation remains a separate engineering task.

**CI:** previous full build had an APK artifact-discovery failure after a long Gradle/Rust build; optimize validation order before retrying full builds.

**Project state:** ready for the next focused implementation cycle, with the UA native integration as the immediate blocker.
