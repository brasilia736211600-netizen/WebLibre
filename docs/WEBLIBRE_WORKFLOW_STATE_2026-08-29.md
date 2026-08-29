# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `49a6f45ea0dfa67622b7a623c35b10094188b727`

## READ THIS FIRST

This is the project's durable execution memory. Do not reconstruct the project from chat history.

### Canonical control documents
- `AGENTS.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md`

The 2026-08-28 documents are historical references only where they do not conflict with this state.

## FINAL PRODUCT

WebLibre has two dependent product tracks.

### Browser foundation
- independent Proxy per container;
- independent User-Agent per container;
- persistence/restoration;
- strict A/B isolation;
- targeted validation;
- stable debug APK;
- release APKs independently downloadable per supported ABI.

### Personal AI Browser Agent
A dedicated owner-only browser-operating agent is an official final-product requirement. It is not the Acode AI Agent and not an OpenRouter-specific feature.

The same Personal Agent Core will be controllable from:

```text
WebLibre in-browser Agent UI ───────┐
Remote phone / Telegram / WhatsApp ─┼─> authenticated control surface
Future channel ─────────────────────┘             ↓
                                          Personal Agent Core
                                                 ↓
                                          Permission Engine
                                                 ↓
                                          Browser Tool API
                                                 ↓
                                               WebLibre
```

Remote inputs are ordinary natural-language instructions and links. Rigid command syntax is not required. Remote authentication identifies the owner/device/channel but does not bypass the normal permission system. Switching between remote and in-browser control must preserve the same task context, grants, memory policy, and audit trail.

## BROWSER STATUS

### Complete
- ContainerMetadata.userAgent data foundation and persistence.
- source Pigeon `AddTabParams.userAgent` contract and generated bindings.
- normal add-tab UA.
- multi-tab UA.
- duplicate-tab UA.
- native session-level UA before first navigation on creation paths.
- existing per-container UA settings UI.

### Current restore slice — IMPLEMENTED, NOT YET RUNTIME-VERIFIED
Android Components SessionStorage does not carry the container UA in TabSessionState, and native cold-start restore occurs before Dart can supply container metadata.

The current solution reuses WebLibre's existing profile-scoped `tab.db` and existing `HistoryDelegateBindingMiddleware`:

1. `ContainerUserAgentStore.kt` reads the existing `container.metadata` JSON from `tab.db`, matched by `contextualIdentity`.
2. `HistoryDelegateBindingMiddleware` reads that value on `EngineAction.LinkEngineSessionAction`.
3. It assigns `engineSession.settings.userAgentString` before continuing downstream.
4. No new Pigeon recovery field, no second DB, no global GeckoRuntime UA, and no Android Components fork were introduced.

A focused parser test file was also added.

### Native API verification
Mozilla's current GeckoView source confirms `GeckoSessionSettings` has a session-level `userAgentOverride`, distinct from runtime-global settings. citeturn823750search0turn823750search1

### Browser restore verification status
The new Kotlin code and tests have not yet been executed in a real Android/native build environment from this interface. Runtime restore and A/B isolation therefore remain unverified.

## CURRENT GIT / PR / CI

- Active branch: `weblibre-ua-mainline-v3`.
- Current HEAD: `49a6f45ea0dfa67622b7a623c35b10094188b727`.
- PR #3: open, draft, base `main`.
- GitHub currently reports the PR as temporarily `mergeable=false`; recheck after the next repository update.
- No CI run is reported for the current HEAD by the available PR-triggered workflow query.
- Historical native CI run `33265003957` passed native runtime prerequisites and Android Kotlin compilation.

## RELEASE APK POLICY

The final release must not force a universal APK. Use the repository's existing `--split-per-abi` builds and publish each supported ABI APK separately. Examples include `arm64-v8a` and `armeabi-v7a`; publish `x86_64` only when it is actually built/supported. A universal APK may be an optional extra.

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

### AI requirements already fixed
- owner-only persistent identity/profile;
- natural-language task understanding;
- links/context as inputs;
- direct in-browser control;
- authenticated remote control from another phone via replaceable transport such as Telegram/WhatsApp;
- task/session/persistent permission grants;
- container/site scopes where useful;
- selectable modes: `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`;
- immediate revocation;
- no silent privilege escalation;
- controlled personal memory;
- explicit Browser Tool Registry;
- model/provider independence;
- correct use of container UA + proxy;
- auditability;
- remote/in-browser task continuity.

## EXACT NEXT EXECUTION

1. Recheck current Git HEAD/PR/status.
2. Run the cheapest available native unit/compile validation for `flutter_mozilla_components`.
3. Validate actual restored-session UA behavior and Container A/B isolation.
4. Validate Proxy restore and A/B isolation.
5. Run Dart analyze/tests and targeted native checks.
6. Build the stable milestone using existing ABI-split APK scripts.
7. Start AI-1 Browser Tool API.

Do not redo completed creation paths or UI.
Do not add global GeckoRuntime UA.
Do not add `RecoverableTab.userAgent` without evidence that the cold-start mechanism requires it.
Do not resurrect `_freshSnapshotPending`.
Do not add a second DB unless the existing profile `tab.db` path proves insufficient.

## CURRENT RESTORE FILES

- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStore.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/HistoryDelegateBindingMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/test/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStoreTest.kt`

## CHECKPOINT RECORD

**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `49a6f45ea0dfa67622b7a623c35b10094188b727`
**Files changed in the latest tracked sequence:** restore store, restore middleware, restore parser test, canonical AI specification, durable workflow state.
**Tests/checks:** parser tests added but not executed here; GeckoView session-level UA API independently confirmed from Mozilla source. No CI run for current HEAD.
**Result:** cold-start UA restore implementation is in place but explicitly unverified; AI Agent now has both direct-browser and authenticated remote-phone control as formal requirements; ABI-split APK delivery remains mandatory.
**Current blocker:** native/runtime validation of restore.
**Exact next action:** run cheapest native validation possible, then A/B UA and proxy validation; after browser milestone, begin AI-1 Browser Tool API.
