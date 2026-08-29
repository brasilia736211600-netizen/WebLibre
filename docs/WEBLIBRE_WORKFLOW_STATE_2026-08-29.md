# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD before this checkpoint:** `84e3b8f90dadee2037d7cb69b41a6cfa60483079`

## READ THIS FIRST

This is the project's durable execution memory. Do not reconstruct the project from chat history.

### Current canonical control documents
- `AGENTS.md` — current repository operating rules.
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md` — current execution state and exact next action.
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` — canonical Personal AI Browser Agent specification.
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md` — current project handoff.
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md` — current continuation prompt.
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md` — current operating playbook.

The 2026-08-28 documents remain historical references unless explicitly reused.

## CURRENT EXECUTION

### Browser foundation
Complete creation paths remain complete. The current blocker is cold-start/restored-tab UA: Android Components SessionStorage does not serialize container UA with TabSessionState, while native restore occurs before Dart can provide container metadata.

**Next browser action:** implement the smallest sound native pre-restore `contextId -> userAgent` persistence/lookup, apply it before restored navigation, then run restore and A/B tests.

Do not redo completed creation paths. Do not add global GeckoRuntime UA. Do not revive `_freshSnapshotPending` arrival-order heuristics.

### Personal AI Browser Agent
Specification is complete; implementation starts after stable browser milestone. It is a dedicated owner-only browser-operating agent, not Acode AI Agent and not an OpenRouter feature. It has explicit selectable permissions including Full Access, revocation, task/session/persistent scopes, container/site scopes, audit history, personal profile, controlled memory, and a model-independent Browser Tool API.

AI sequence:

`AI-1 Browser Tool API -> AI-2 Agent Core -> AI-3 Personal Profile/Memory -> AI-4 Permission Engine -> AI-5 workflows -> AI-6 advanced behavior -> AI-7 model adapters -> AI-8 validation`.

### Permanent APK requirement
Final Android artifacts must be independently downloadable per supported ABI, not forced into one universal APK. Current repository build scripts already use Flutter `--split-per-abi` for stable and alpha APK builds; preserve that behavior and publish each ABI artifact separately (for example `arm64-v8a`, `armeabi-v7a`, and `x86_64` when supported). A universal APK may only be provided as an optional extra.

## CHECKPOINT

**Branch:** `weblibre-ua-mainline-v3`
**HEAD at checkpoint start:** `84e3b8f90dadee2037d7cb69b41a6cfa60483079`
**Files changed in the documentation checkpoint:**
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

**Tests/results:** documentation-only. No source-code behavior changed. Verified `pubspec.yaml` already invokes `flutter build apk ... --split-per-abi` for stable/alpha/legacy release builds, so no unnecessary build-script modification was made.

**Exact next step:** return to the UA cold-start restore blocker. Inspect/modify only the minimal native persistence/restore path, then test restore + A/B UA isolation, followed by proxy regression validation.

**After browser milestone:** begin AI-1 Browser Tool API without waiting for a new chat or re-explaining project context.

Required loop remains:
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`
