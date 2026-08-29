# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `49a6f45ea0dfa67622b7a623c35b10094188b727`

## READ THIS FIRST

This is the project's durable execution memory. Do not reconstruct the project from chat history.

### Current canonical control documents
- `AGENTS.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md`

The 2026-08-28 documents are historical references only when they do not conflict with this state.

## FINAL PRODUCT

WebLibre has two dependent product tracks:

1. Privacy-oriented browser foundation: per-container Proxy + User-Agent, persistence/restore, strict A/B isolation, validation, release.
2. Personal AI Browser Agent: owner-only, model/provider independent, operates the real browser through an explicit Browser Tool API, has user-controlled memory and selectable/revocable permissions including Full Access.

The Personal AI Agent is NOT the Acode AI Agent and is NOT an OpenRouter feature.

It has multiple control surfaces using one Agent Core:

```text
WebLibre in-browser UI ───────┐
Remote phone / Telegram /    ├─> Authenticated Control Gateway
WhatsApp / future channel ───┘             ↓
                                      Personal Agent Core
                                             ↓
                                      Permission Engine
                                             ↓
                                      Browser Tool API
                                             ↓
                                          WebLibre
```

Remote messages are normal natural-language tasks and can include links, context, constraints, and follow-up corrections. The agent must infer the needed browser sequence rather than requiring rigid command syntax. Remote authentication identifies the owner/device/channel but never bypasses the normal Permission Engine. The transport is replaceable; the Agent Core and permissions are not.

Canonical AI spec: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

## BROWSER STATUS

### Complete
- `ContainerMetadata.userAgent` data foundation and persistence.
- source Pigeon `AddTabParams.userAgent` contract and generated bindings.
- normal add-tab UA.
- multi-tab UA.
- duplicate-tab UA.
- native session-level UA before first navigation on creation paths.
- existing per-container UA settings UI.

### Current restore work — IMPLEMENTED, NOT YET RUNTIME-VERIFIED
The existing per-profile `tab.db` is the source of truth used by Dart for container metadata. Native `ProfileContext.getDatabasePath()` points at that profile's database directory.

Added:
- `ContainerUserAgentStore.kt`: read-only lookup of `ContainerMetadata.userAgent` from the existing `container.metadata` JSON in `tab.db`, matched by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt`: on `EngineAction.LinkEngineSessionAction`, read the persisted UA from the existing profile DB and assign `engineSession.settings.userAgentString` before `next(action)` continues downstream linking/loading.
- `ContainerUserAgentStoreTest.kt`: focused parser tests for matching container, cross-container isolation, blank/default behavior, and malformed metadata.

Design intentionally avoids:
- a second persistence database;
- a new Pigeon recovery field;
- global GeckoRuntime UA;
- an Android Components fork;
- `syncEvents` arrival-order heuristics.

The implementation still requires execution in a real Android/native build and an end-to-end restored-tab test before UA restore is marked complete.

### Restore invariant

```text
existing container row in profile tab.db
        -> contextualIdentity + metadata.userAgent
        -> restored EngineSession link
        -> session UA applied
        -> downstream linking/navigation
```

If the database is absent, unavailable, or malformed, lookup fails safely and the session keeps the normal/default UA rather than crashing.

## CURRENT GIT / PR / CI

- Active branch: `weblibre-ua-mainline-v3`.
- Current HEAD: `49a6f45ea0dfa67622b7a623c35b10094188b727`.
- PR #3 is open and draft against `main`.
- Latest PR metadata reports `mergeable=false` at the time of this checkpoint; recheck after the next push because this may be transient GitHub mergeability state.
- No CI workflow run is reported for the current HEAD by the PR-triggered workflow query.
- Historical native CI run `33265003957` passed native runtime prerequisites and Android Kotlin compilation.

## CURRENT RESTORE COMMITS

Recent feature-chain commits, all in the active branch history:
- `31ff87d...` — add `ContainerUserAgentStore`.
- `64e196c...` — bind the actual profile context.
- `435999f...` — avoid native SQLite JSON1 dependency.
- `8ad5f98...` — add parser visibility for tests.
- `9f74216...` — remove unnecessary test annotation.
- `2f6e266...` — add focused parser tests.
- `394d17a...` — save the durable restore checkpoint.
- `49a6f45...` — extend the canonical AI specification with direct and remote control surfaces.

A temporary attempt to add a quality workflow via the GitHub contents API was detected to have created the file on `main` instead of the feature branch. That workflow file was immediately deleted from `main`; it is **not part of the feature branch** and must not be recreated using the same unsafe path. No lingering `quality.yml` file remains on the feature branch as a result of that attempt.

## TESTING CHECKPOINT

Tests added for the new parser path:
- matching container returns trimmed UA;
- different container is ignored;
- blank UA becomes null/default;
- malformed JSON is ignored.

**Execution status:** not yet run in an actual build environment from this interface. Therefore native compile and runtime restore are still unverified.

A web check of GeckoView's current `GeckoSessionSettings` confirms that `userAgentOverride` is a real session-level setting and is distinct from global runtime state. citeturn823750search0turn823750search1

## EXACT NEXT EXECUTION

1. Validate the current restore code with the cheapest available Android/native compile or unit-test path.
2. If compilation is clean, run a restored-tab scenario and verify Container A/Container B retain distinct UAs.
3. Validate proxy restore and A/B isolation.
4. Run Dart analyze/tests and targeted native checks.
5. Build the stable milestone using the existing ABI-split APK scripts.
6. Start AI-1 Browser Tool API immediately after the browser milestone.

Do not redo completed UA creation/UI work.
Do not add global GeckoRuntime UA.
Do not add `RecoverableTab.userAgent` merely as a cosmetic fix.
Do not resurrect `_freshSnapshotPending`.
Do not add another database unless the existing profile `tab.db` path proves insufficient.

## PERSONAL AI AGENT ROADMAP

```text
AI-0 Specification                       [x]
AI-1 Browser Tool API                   [ ]
AI-2 Agent Core                         [ ]
AI-3 Personal Profile + Memory         [ ]
AI-4 Permission Engine                 [ ]
AI-5 First autonomous workflows        [ ]
AI-6 Advanced personal behavior        [ ]
AI-7 Model/provider adapters            [ ]
AI-8 End-to-end validation              [ ]
```

AI-1 must inventory existing WebLibre capabilities and expose a small stable Browser Tool API with schemas, permission requirements, side-effect/reversibility metadata, and audit events.

Later AI stages must implement the task loop, owner profile/memory, selectable permissions including Full Access, autonomous workflows, model adapters, and end-to-end validation. Both direct in-browser and authenticated remote control must feed the same Agent Core/task context.

## RELEASE APK POLICY

Final release artifacts must be independently downloadable per supported ABI, not forced into one universal APK. Existing stable/alpha/alphaLegacy scripts already use `--split-per-abi`; preserve them and publish each supported ABI APK as a separate artifact. A universal APK is optional only.

## MANDATORY AGENT LOOP

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

After every meaningful implementation/checkpoint update this file with branch, HEAD, files, tests/results, blocker, and exact next action.

## CHECKPOINT RECORD

**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `49a6f45ea0dfa67622b7a623c35b10094188b727`
**Files changed in the current implementation/documentation sequence:**
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStore.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/HistoryDelegateBindingMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/test/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStoreTest.kt`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`

**Tests/checks:** parser tests added; not yet executed here. GeckoView session-UA API independently confirmed by current Mozilla source documentation. CI has not run on the current feature HEAD.

**Result:** native cold-start UA restore path implemented using the existing profile DB and existing session-link middleware, with no new Pigeon recovery field. Personal AI Agent now explicitly supports direct WebLibre control plus authenticated remote-phone control. ABI-separated APK delivery is permanent.

**Current blocker:** real native compile/runtime verification of the restore path.

**Exact next action:** validate the new native restore slice; then A/B UA isolation, proxy regression, targeted validation, stable ABI-split APK, and only then AI-1 Browser Tool API.
