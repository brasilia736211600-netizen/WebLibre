# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `2f6e26683786403f74af6cc1f369153119ca3091`

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

1. Privacy-oriented browser foundation: per-container Proxy + User-Agent, persistence/restore, strict isolation, validation, release.
2. Personal AI Browser Agent: owner-only, model/provider independent, operates the real browser through an explicit Browser Tool API, has user-controlled memory and selectable/revocable permissions including Full Access.

The Personal AI Agent is NOT the Acode AI Agent and is NOT an OpenRouter feature.

The agent will have multiple control surfaces using one Agent Core:

```text
WebLibre in-browser UI ───────┐
                             ├─> Personal Agent Core
Remote phone / Telegram /    │       -> Permission Engine
WhatsApp / future channel ───┘       -> Browser Tool API
                                         -> WebLibre
```

Remote control must authenticate the owner/device/channel and use the same permission system as the in-browser interface. Natural-language task instructions and supplied links are first-class inputs; the agent must infer the required sequence of browser operations rather than requiring rigid command syntax.

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
The existing per-profile `tab.db` is the same source of truth used by Dart for container metadata. `ProfileContext.getDatabasePath()` points native callers at the selected profile's database directory. A new small native `ContainerUserAgentStore` reads persisted container `metadata` from the existing `container` table and returns the matching `userAgent` by `contextualIdentity`.

`HistoryDelegateBindingMiddleware` now uses that store on `EngineAction.LinkEngineSessionAction` and assigns `engineSession.settings.userAgentString` before calling `next(action)`. This reuses the already-existing pre-link middleware hook; no new Pigeon recovery field, no second database, and no Android Components fork were added.

This is the smallest currently identified cold-start restore path. It must still be validated by an actual native build/test and, ideally, an end-to-end restored-tab run.

### Restore invariant

```text
persisted container.contextualIdentity
        + persisted container.metadata.userAgent
        -> restored EngineSession link
        -> session UA applied
        -> downstream linking/load
```

If persisted lookup fails (database absent/locked/unreadable or malformed row), the implementation logs and falls back without crashing. A malformed unrelated row does not prevent another container's row from being found.

## CURRENT GIT / PR / CI

- Active branch: `weblibre-ua-mainline-v3`.
- Current HEAD: `2f6e26683786403f74af6cc1f369153119ca3091`.
- PR #3 is open, draft, base `main`, and currently reports mergeable.
- No status checks were reported for the earlier `64e196c...` code checkpoint; a current status/PR recheck is required after the latest commits.
- Historical native CI run `33265003957` passed native runtime prerequisites and Android Kotlin compilation.

## FILES CHANGED IN CURRENT RESTORE SLICE

- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStore.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/HistoryDelegateBindingMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/test/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStoreTest.kt`

The restore implementation intentionally does not modify the Pigeon contract or Android Components dependency.

## TESTING CHECKPOINT

A focused unit-test file was added for persisted metadata parsing:
- matching container returns trimmed UA;
- different container is ignored;
- blank UA is treated as default/null;
- malformed metadata is ignored.

Those tests have **not yet been executed in an actual build environment from this interface**. Therefore the restore feature remains marked `IMPLEMENTED, NOT YET RUNTIME-VERIFIED`.

The native package's Gradle configuration uses JVM unit tests and has the required Kotlin test and `org.json` test dependencies.

## NEXT EXECUTION

1. Recheck current HEAD/PR/status.
2. Run the cheapest available native unit/compile validation for `flutter_mozilla_components`.
3. If compilation passes, validate the restore lifecycle and container A/B UA isolation.
4. Then validate per-container Proxy restore/A-B behavior.
5. When browser foundation is stable, build the milestone APK using existing `--split-per-abi` scripts.
6. Then begin AI-1 Browser Tool API.

Do not redo any completed UA creation path.
Do not add global GeckoRuntime UA.
Do not resurrect `_freshSnapshotPending`.
Do not add a new persistence subsystem unless the current `tab.db` path proves insufficient.

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

AI-1 must inventory existing WebLibre capabilities first and expose only stable, explicit browser tools with permission requirements, input/output schemas, side-effect/reversibility metadata, and audit events.

The final AI implementation must support:
- in-browser control;
- remote control from another phone through Telegram/WhatsApp or another authenticated channel;
- natural-language goals plus links/context;
- owner-only persistent identity/profile;
- inspectable/editable/exportable/deletable memory;
- permission modes `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`;
- task/session/persistent and container/site-scoped grants where useful;
- immediate revocation;
- no silent privilege escalation;
- model/provider replacement without redesign.

## RELEASE APK POLICY

Final release artifacts must be independently downloadable per supported ABI, not forced into a single universal APK. The existing `pubspec.yaml` build scripts already use `--split-per-abi` for stable/alpha/legacy. Preserve that behavior and publish each supported ABI APK as its own artifact. A universal APK may only be an optional extra.

## MANDATORY AGENT LOOP

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

After every meaningful step update this file with:
- branch;
- HEAD;
- files changed;
- tests/checks and exact result;
- current blocker;
- exact next action.

## CHECKPOINT RECORD

**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `2f6e26683786403f74af6cc1f369153119ca3091`
**Work completed:** implemented the minimal native persisted-container-UA lookup and bound it in the existing session-link middleware; added focused parser tests.
**Tests/results:** tests added but not yet executed from this interface.
**Result:** code path is implemented with no new Pigeon contract, no second persistence store, and no upstream Android Components fork.
**Current blocker:** runtime/native validation of the new restore path.
**Exact next action:** run the cheapest native unit/compile validation available, then perform restore/A-B isolation verification.
