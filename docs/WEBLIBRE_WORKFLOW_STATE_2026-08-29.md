# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `c999491cfd6fd78a96564c8f4661712da3a360c4`

## READ THIS FIRST

This is the project's durable execution memory. Do not reconstruct the project from chat history.

### Canonical control documents
- `AGENTS.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md`

## FINAL PRODUCT

WebLibre has two dependent tracks: the privacy/container browser foundation and a first-class Personal AI Browser Agent.

The Personal AI Agent is owner-only, model/provider independent, and operates the real WebLibre browser through an explicit Browser Tool API. It has controlled memory and selectable/revocable permissions, including user-granted Full Access.

It has both direct and remote control surfaces using the same Agent Core:

```text
WebLibre Agent UI ─────────────┐
Remote phone / Telegram /     ├─> authenticated control gateway
WhatsApp / future channel ────┘             ↓
                                      Personal Agent Core
                                             ↓
                                      Permission Engine
                                             ↓
                                      Browser Tool API
                                             ↓
                                          WebLibre
```

Remote tasks accept ordinary natural language, links, context, constraints, and follow-up corrections. Remote authentication never bypasses permissions. The transport remains replaceable.

Canonical AI specification: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

## BROWSER STATUS

### Complete
- ContainerMetadata.userAgent data foundation and persistence.
- source Pigeon AddTabParams.userAgent contract/generated bindings.
- normal/multi/duplicate UA creation paths.
- native session-level UA before first navigation on those paths.
- existing per-container UA settings UI.

### Restore slice — implemented, runtime-unverified
Android Components SessionStorage does not persist container UA in TabSessionState. The current local solution reads the existing per-profile `tab.db` container metadata by `contextualIdentity` and applies the persisted UA during the existing `HistoryDelegateBindingMiddleware` session-link hook before downstream linking/navigation.

Changed files:
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStore.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/HistoryDelegateBindingMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/test/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStoreTest.kt`

No new Pigeon recovery field, second database, global GeckoRuntime UA, or Android Components fork was introduced.

## CURRENT GIT / PR / CI

- Active branch: `weblibre-ua-mainline-v3`.
- Current HEAD: `c999491cfd6fd78a96564c8f4661712da3a360c4`.
- PR #3: open, draft, base `main`; GitHub currently reports it mergeable.
- No workflow run is reported for the current HEAD through the available PR-run query.
- Historical native CI run `33265003957` passed native runtime prerequisites and Android Kotlin compilation.

A temporary attempt to create a quality workflow through the contents API created a commit on `main` instead of the feature branch. The file was immediately deleted from `main`; the quality workflow is not present on the feature branch and must not be recreated through that unsafe write path.

## TESTING CHECKPOINT

Focused parser tests exist for matching container UA, cross-container isolation, blank/default behavior, and malformed JSON. They have not been executed here.

A direct `git clone` attempt in the execution environment failed because `github.com` could not be resolved (DNS/network restriction), so local native compilation cannot be performed from this environment. This is an environment limitation, not evidence of a code failure.

Mozilla GeckoView source independently confirms the session-level `userAgentOverride` API used by the design. citeturn823750search0turn823750search1

## EXACT NEXT EXECUTION

1. Run the focused native/Kotlin test and compile from an environment with repository/network access (Acode/Termux or GitHub Actions).
2. Fix any compile/test issue introduced by the restore slice only.
3. Verify real cold-start restored UA and Container A/B UA isolation.
4. Verify Proxy restore/A-B isolation.
5. Run Dart analyze/tests and targeted native checks.
6. Build stable milestone with existing `--split-per-abi` scripts and publish supported ABI APKs independently.
7. Start AI-1 Browser Tool API.

Do not redo completed UA creation/UI work. Do not add a global GeckoRuntime UA. Do not resurrect `_freshSnapshotPending`. Do not add a second DB unless the existing profile `tab.db` path proves insufficient.

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

AI requirements already fixed:
- natural-language goals and supplied links;
- direct in-browser control;
- authenticated remote control from another phone through replaceable messaging transport;
- same task context across remote/in-browser surfaces;
- owner-only persistent identity/profile;
- inspectable/editable/exportable/deletable/disableable memory;
- `Read Only | Browser Control | Task Control | Trusted Automation | Full Access`;
- task/session/persistent and container/site scopes where useful;
- immediate revocation;
- no silent privilege escalation;
- explicit Browser Tool Registry and auditability;
- model/provider independence.

## RELEASE APK POLICY

Final release must provide each supported ABI APK as an independently downloadable artifact. Preserve the existing Flutter `--split-per-abi` build behavior. Examples include `arm64-v8a` and `armeabi-v7a`; only publish `x86_64` when actually built/supported. Universal APK is optional.

## MANDATORY AGENT LOOP

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

After every meaningful checkpoint update branch, HEAD, changed files, checks/results, blocker, and exact next action.

## CHECKPOINT RECORD

**Date:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `c999491cfd6fd78a96564c8f4661712da3a360c4`
**Files changed in the latest feature work:** restore store, restore middleware, restore parser test, AI specification, workflow state and control documentation.
**Tests/checks:** parser tests added but not executed here; current GeckoView source confirms session-level UA API; local clone/compile attempt blocked by DNS/network access.
**Result:** restore implementation remains explicitly runtime-unverified. Personal AI remote + in-browser control and Full Access permissions are permanently specified. ABI-separated APK delivery remains mandatory.
**Current blocker:** native test/compile and real restore/A-B verification require an environment with repository/build access.
**Exact next action:** execute focused native test/compile externally; then restore/A-B, proxy regression, targeted validation, ABI-split milestone APK, then AI-1.
