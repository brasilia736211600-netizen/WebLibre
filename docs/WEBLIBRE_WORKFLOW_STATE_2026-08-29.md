# WebLibre — Durable Workflow State

**Date:** 2026-08-29  
**Branch:** `weblibre-ua-mainline-v3`  
**HEAD at checkpoint:** `edca33b5cb2885261a002092b1a72d6d95dfff27`

## Purpose

This file records the exact engineering workflow and checkpoint so a later AI agent can resume without reconstructing the project from chat history.

## Current objective

Complete the per-container User-Agent runtime path in the existing WebLibre fork. Do not rebuild the application and do not move UA policy to global GeckoRuntime state.

## Verified architecture facts

- `packages/flutter_mozilla_components/android/build.gradle` uses Android Components `152.0.4`.
- Android Components includes `browser-engine-gecko`, `concept-engine`, `feature-session`, and related browser components.
- `GeckoEngineSession` exposes a session-level `userAgentString` backed by `geckoSession.settings.userAgentOverride`.
- `TabsUseCases.RestoreUseCase` restores tabs through `TabListAction.RestoreAction`.
- `RecoverableTab.toTabSessionState()` carries an `engineSessionState`, but the current recovery model does not carry a per-container UA field.
- `TabListReducer` converts restored `RecoverableTab` objects into tab session states; it is not the correct place to configure Gecko UA.
- The critical local integration boundary is the native tab/session creation path (`GeckoTabsApiImpl` and the concrete EngineSession creation flow).

## Current UA state

### Completed

- `ContainerMetadata` contains `String? userAgent`.
- UA persistence/model serialization and normalization were implemented and tested.
- The intended invariant is established:

```text
ContainerMetadata.userAgent
    -> tab/session creation
    -> EngineSession / GeckoSession userAgent override
    -> first navigation
```

### Not completed

- UA is not yet propagated through the actual tab-creation/Pigeon contract.
- Native EngineSession UA application is not yet implemented.
- `addTab`, `addMultipleTabs`, and `duplicateTab` coverage is not yet complete.
- Restore/recovery UA handling is not yet complete.
- Runtime isolation test for two containers with different UAs is not yet complete.
- Per-container UA settings UI is not yet complete.

## Execution workflow

Every coding cycle must follow:

```text
inspect current HEAD
    -> inspect exact source path
    -> define smallest safe change
    -> implement one vertical slice
    -> regenerate Pigeon when source contract changes
    -> run targeted tests/checks
    -> inspect git diff against base
    -> verify no unrelated files changed
    -> atomic commit
    -> record branch/HEAD/tests/next blocker here
```

Do not skip the inspection phase because earlier chat messages suggested a design.

## Immediate next sequence: UA runtime

### UA-01 — contract

1. Inspect the exact current Pigeon source for tab creation (`packages/flutter_mozilla_components/pigeons/gecko.dart`).
2. Identify `AddTabParams` and all callers/implementations.
3. Add `userAgent` to the SOURCE contract only if the current API confirms this is the correct boundary.
4. Regenerate Pigeon using the project's official generation command.
5. Do not hand-edit generated output as a source of truth.
6. Run targeted compile/analyze checks.

### UA-02 — propagation

1. Find the Dart caller that already knows the assigned container.
2. Pass that container's normalized UA into the tab-creation request.
3. Keep container state architecture unchanged.
4. Run targeted Dart tests.

### UA-03 — native session

1. Inspect the exact current `GeckoTabsApiImpl` and EngineSession creation path.
2. Create the EngineSession before the first navigation.
3. Apply the per-container UA to that session.
4. Create the tab state with the prepared session.
5. Dispatch `AddTabAction`.
6. Only after UA application, allow the first `LoadUrlAction`.

Required conceptual order:

```text
create EngineSession
    -> set UA
    -> create TabSessionState with prepared session
    -> AddTabAction
    -> LoadUrlAction
```

Do not use a global GeckoRuntime UA setting.

### UA-04 — tab variants

Verify separately:

- normal `addTab`;
- `addMultipleTabs`;
- duplicate tab creation.

### UA-05 — restore

Treat restored tabs as a separate lifecycle. Verify that the recovered session cannot perform its first navigation with the wrong/default UA before the container policy is applied.

### UA-06 — isolation

Add the smallest meaningful runtime regression test demonstrating:

```text
Container A -> UA-A
Container B -> UA-B
A changes -> B remains UA-B
```

### UA-07 — UI

Only after runtime behavior and isolation pass, add or finish per-container UA settings UI and reset/default behavior.

## Separate forensic track: restore/event correlation

This is a distinct problem and must not be mixed into the UA implementation unless new evidence requires it.

Current conclusion:

- `syncEvents()` returns `Future<void>`.
- Tab-list events contain sequence numbers but no request/generation provenance.
- Stale debounced events may already be queued.
- RPC and GeckoStateEvents use separate channels.
- Awaiting `syncEvents()` does not prove that the next tab-list event was caused by that request.

Therefore `_freshSnapshotPending`-style arrival-order heuristics are unsound. Reliable correlation requires explicit provenance, such as a sequence/generation boundary or request ID, followed by Pigeon regeneration.

## Build/test discipline

Because full APK builds are expensive and a prior full build reached a late APK artifact-discovery failure, use:

```text
Dart/unit tests
-> analyze
-> targeted Kotlin/native checks
-> Pigeon generation check
-> targeted integration/build
-> full APK only at a stable milestone
```

Do not rerun a full APK build merely to diagnose a narrow compiler/test failure.

## Git discipline

- Work only on `weblibre-ua-mainline-v3` for this feature checkpoint unless a new dedicated feature branch is intentionally created.
- Never use `main` as a scratch branch.
- Inspect existing file contents before updating them.
- Keep commits atomic and reviewable.
- Compare significant changes against `main`.
- Stop on unexpected mass diffs or generated-file churn.
- Do not modify the upstream reference repository.

## Low-credit agent workflow

For an AI coding agent:

1. Read this file plus the canonical handoff and operating playbook.
2. Inspect actual current HEAD before editing.
3. Work on exactly one numbered UA slice at a time.
4. Run only the smallest validating tests.
5. Inspect diff and commit atomically.
6. Update this file with concrete evidence.

Progress reports must contain:

- branch;
- HEAD SHA;
- files changed;
- tests/checks executed;
- result;
- exact next blocker or next implementation point.

Avoid giant prompts and avoid repeating the entire project context in each task.

## Current checkpoint

The investigation has now moved past the abstract GeckoView capability question. The next work item is to inspect the concrete native session creation path and prove exactly where the prepared `GeckoEngineSession` is constructed for a newly created/restored tab.

**Next action:** inspect current `GeckoTabsApiImpl` + Pigeon tab-creation contract together, then implement only UA-01/UA-02 if the source confirms the boundary. Do not start UI work and do not touch the separate `syncEvents` provenance problem yet.
