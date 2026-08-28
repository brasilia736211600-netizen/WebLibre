# Genspark Continuation Prompt — WebLibre

You are taking over an active engineering project named WebLibre.

## Critical instruction: create a NEW fork first

DO NOT modify, push to, merge into, or otherwise alter the user's current/reference repository directly:

`https://github.com/brasilia736211600-netizen/WebLibre`

Your first repository operation must be to create a NEW fork/copy of that repository under the account/workspace available to you. All implementation, experiments, commits, branches, CI changes, and tests must happen in that NEW fork only.

The original repository is the reference/source project and must remain untouched.

After creating the fork, preserve the complete current repository history and then continue from the latest relevant feature state. Do not rebuild the application from scratch.

## Read this first

The reference repository contains a durable handoff map:

`docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`

Read it completely before making changes.

Also inspect:

- the current default branch;
- the existing UA feature branch/PR if still present;
- the latest commits;
- the working tree/diff against mainline;
- existing CI workflows;
- the local `flutter_mozilla_components` package.

## Project goal

Complete the user's WebLibre fork as a privacy-oriented browser with independent container-level network/browser identity.

The agreed feature requirements include:

1. Independent Proxy for every container.
2. Independent User-Agent for every container.
3. Per-container settings allowing the user to customize these values independently.
4. Persistence and restoration of those settings.
5. Strict isolation: changing Container A must not change Container B.
6. Preserve the existing WebLibre architecture and avoid unnecessary upstream forks.

## User-Agent status

The data foundation is already implemented in the reference work:

- `ContainerMetadata.userAgent` exists.
- JSON persistence exists.
- `copyWith` exists.
- equality/normalization behavior exists.
- targeted persistence tests exist.

Do NOT treat this as a complete UA feature.

The remaining work is runtime integration.

## Correct UA architecture

UA must be applied at the GeckoSession/EngineSession level, not globally at GeckoRuntime level.

The intended lifecycle is:

ContainerMetadata.userAgent
    -> tab/session creation
    -> create EngineSession
    -> apply session userAgentString / override
    -> create tab state using that prepared session
    -> AddTabAction
    -> LoadUrlAction

The UA must be applied BEFORE the first navigation.

Do not use a delayed `setUserAgent` after navigation as the primary design.

## Native integration point already identified

The local package:

`packages/flutter_mozilla_components/`

contains the Android/Kotlin integration.

`GeckoTabsApiImpl` is the critical native point. Its current conceptual flow is:

`addTab()`
 -> create TabSessionState
 -> AddTabAction
 -> LoadUrlAction

Android Components supports creating a tab with a prepared `engineSession`. Use that capability to establish the UA before loading the URL.

The project dependency version investigated is Android Components `152.0.4`.

## Recommended implementation sequence

1. Inspect the exact current Pigeon source defining `AddTabParams` and the relevant `GeckoTabsApi` method.
2. Add `userAgent` to the SOURCE contract only.
3. Run the project's official Pigeon generation process.
4. Update Dart code so the assigned container's `ContainerMetadata.userAgent` reaches tab creation.
5. Update `GeckoTabsApiImpl` so it creates/prepares the EngineSession with the UA before the first load.
6. Cover `addTab`.
7. Cover `addMultipleTabs`.
8. Cover `duplicateTab`.
9. Design restore separately so restored sessions cannot navigate with the wrong/default UA first.
10. Add a runtime isolation test proving Container A and Container B can use different UAs simultaneously.
11. Only after runtime behavior is verified, add/finish the per-container settings UI.

## Proxy requirement

Proxy must remain independent per container.

Verify that:

- Container A can use Proxy A.
- Container B can use Proxy B.
- changing A does not mutate B;
- new sessions receive the correct container proxy;
- restored sessions retain the correct proxy policy;
- no accidental global GeckoRuntime proxy state is introduced.

## Restore/event forensic issue

A separate investigation established that the current `syncEvents()` API is not mathematically sufficient to correlate a returned tab-list event with a particular request because:

- `syncEvents()` returns `Future<void>`;
- no request/generation token is returned;
- tab-list events contain sequence information but no request provenance;
- stale debounced events can already be queued;
- RPC and GeckoStateEvents use separate channels.

The previously proposed `_freshSnapshotPending` approach was rejected as unsound.

If reliable request/event correlation is needed, introduce explicit sequence/generation/request provenance and regenerate Pigeon. Do not reintroduce arrival-order heuristics as if they were reliable.

## Build/CI constraints

A previous debug APK workflow reached Gradle after Rust builds and spent about 756 seconds before failing because the expected APK artifact could not be found:

`Gradle build failed to produce an .apk file. It's likely that this file was generated under /home/runner/work/WebLibre/WebLibre/apps/weblibre/build, but the tool couldn't find it.`

Therefore do not repeatedly run expensive full APK builds before targeted checks pass.

Preferred validation order:

1. Dart unit tests.
2. `flutter analyze`.
3. targeted Kotlin/native checks.
4. Pigeon generation consistency.
5. targeted integration/build.
6. full APK build only at a stable milestone.

## Git safety rules

- Work ONLY in the newly created fork.
- Never push experiments to the original repository.
- Use dedicated feature branches.
- Keep commits atomic and reviewable.
- Before changing an existing file, inspect its current content/SHA.
- Never overwrite large generated files from partial snippets.
- Generate Pigeon output from source rather than hand-editing generated output whenever possible.
- Compare every feature branch against its base after significant changes.
- If unrelated deletions appear, stop and repair them before proceeding.

## Definition of done

The project is NOT done when `ContainerMetadata.userAgent` merely persists.

The UA feature is done only when all of the following are true:

- [ ] custom UA can be configured for a container;
- [ ] value persists;
- [ ] value restores;
- [ ] new tabs use it before first navigation;
- [ ] multiple tabs preserve the correct container UA;
- [ ] duplicated tabs preserve the correct UA;
- [ ] restored tabs use the correct UA before navigation;
- [ ] two containers can use different UAs concurrently;
- [ ] clearing UA returns that container to default behavior;
- [ ] UI changes affect only the selected container;
- [ ] tests cover regressions.

Proxy is similarly complete only after runtime isolation and restore behavior are verified.

## Working style

Act as a senior software engineer/release engineer, not as a conversational assistant.

Do not spend long cycles merely describing what you intend to do.

Prefer this loop:

inspect -> implement -> test -> inspect diff -> commit -> continue

Report concrete evidence:

- branch name;
- commit SHA;
- files changed;
- tests run;
- test results;
- remaining blockers.

Never claim a feature is implemented unless the code and tests demonstrate it.

## Immediate first mission

Create the NEW fork, read `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`, inspect the current repository state, and then implement the UA runtime vertical slice described above.

Do not modify the original repository.
Do not restart from scratch.
Do not discard the existing history.
Continue from the current engineering state.
