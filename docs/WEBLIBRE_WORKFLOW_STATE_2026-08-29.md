# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `1eb7d5e5ef70e014842a601985ba791aafad7af5`

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

## 1. FINAL PRODUCT

WebLibre has two dependent tracks.

### Browser foundation
- independent Proxy per container;
- independent User-Agent per container;
- persistence/restoration;
- strict A/B isolation;
- targeted validation;
- stable APK;
- final release.

### Personal AI Browser Agent
The final browser must include a dedicated personal AI agent for the owner/user. It must operate the real browser through explicit tools, maintain user-controlled profile/memory, and remain model/provider independent.

This is not the Acode AI Agent and not merely an OpenRouter integration.

Canonical spec: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

## 2. BROWSER STATUS

### Complete
- ContainerMetadata.userAgent data foundation.
- Source Pigeon AddTabParams.userAgent contract.
- Normal tab UA path.
- Multiple-tab UA path.
- Duplicate-tab UA path.
- Native per-session UA before first navigation for creation paths.
- Existing container UA settings UI.

### Current blocker
Cold-start/restored-tab UA. Android Components SessionStorage does not serialize the container UA with TabSessionState, and native restore occurs before Dart can provide container metadata.

### Exact next browser action
Find the smallest sound native pre-restore persistence/lookup mechanism for `contextId -> userAgent`, apply it before restored navigation, then run restore/A-B tests and targeted validation.

Do not redo completed creation paths. Do not add a global GeckoRuntime UA. Do not revive `_freshSnapshotPending` arrival-order heuristics.

## 3. PERSONAL AI AGENT — PRODUCT REQUIREMENT

### Status
Specification complete; implementation not started.

The agent must be a real browser-operating agent, not only a chat surface:

```text
User goal
 -> Agent Core
 -> Permission Engine
 -> Browser Tool Registry
 -> WebLibre Browser API
 -> live GeckoView browser state
 -> observe result
 -> next action
```

### Owner-only profile
Persistent profile for one owner containing instructions, preferences, workflows, trusted sites, memory policy, and permissions. Changing the model/provider must not erase this identity.

### Full user-controlled permissions
The owner can grant complete browser capabilities as selectable permissions according to the task.

Required scopes include browser-state read, page/content read, navigation, interaction, tabs, downloads/files, authenticated sessions when granted, containers, proxy, UA, browser settings, external actions, and future WebLibre capabilities.

Modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

Full Access is an explicit owner grant for all currently exposed capabilities within the selected scope. Grants support one-task, session, persistent, container-scoped, and where useful site/domain-scoped lifetimes. Revocation is immediate. The agent cannot silently escalate.

### Memory/data
Memory is separate from browser state and user controlled. The user can inspect, edit, export, clear, or disable it. Arbitrary page content must not silently become permanent memory. Only task-required information should be sent to a model provider.

### Tool boundary
The model receives no unrestricted WebLibre API access. Each tool declares permissions, input/output schemas, side effects, reversibility, and audit metadata.

### Candidate technology
Browser Use is the primary reference/candidate; Stagehand and Skyvern are secondary references. Do not embed one blindly. Define WebLibre's internal tool boundary first.

## 4. AI ROADMAP

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

### AI-1
Inventory existing WebLibre browser capabilities and build the smallest internal Browser Tool Registry. Add schemas, permission requirements, side-effect/reversibility metadata, and audit events.

### AI-2
Plan/reason/act/observe loop, context builder, model adapter boundary, retries/timeouts, and stop criteria.

### AI-3
Owner profile, preferences/instructions, short-term and long-term memory, retention/delete controls, and data minimization.

### AI-4
All permission modes, granular grants, task/session/persistent scopes, container/site scopes, Full Access, revocation, and audit history.

### AI-5 onward
First autonomous workflows, advanced personal behavior, model adapters, optimization, and end-to-end validation as defined in the canonical AI spec.

## 5. PROXY

Proxy remains per-container and never global. Final verification must prove:

`A -> Proxy-A`, `B -> Proxy-B`, changing A does not change B, and restore preserves policy.

## 6. RESTORE/EVENT FORENSICS

`syncEvents()` currently provides no request/generation provenance. Tab-list arrival order is not proof of causation. `_freshSnapshotPending` remains rejected as unsound. Touch this only if the restore implementation actually requires reliable event correlation.

## 7. FINAL PROJECT SEQUENCE

```text
UA restore
 -> UA A/B isolation
 -> Proxy restore/A-B verification
 -> targeted validation
 -> stable debug APK
 -> AI-1 Browser Tool API
 -> Agent Core
 -> Permission Engine
 -> Personal Profile + Memory
 -> autonomous workflows
 -> model adapters
 -> end-to-end validation
 -> release APK
```

## 8. GIT / CI CHECKPOINT

- Active branch: `weblibre-ua-mainline-v3`.
- PR #3 remains open and draft against `main`.
- Current HEAD: `1eb7d5e5ef70e014842a601985ba791aafad7af5`.
- Historical native CI run `33265003957` passed the native runtime prerequisites and Kotlin compilation.
- Documentation/specification checkpoint only; no source-code behavior was changed by this update.

## 9. NEW-CHAT RULE

A new agent must not ask the user to re-explain the project. It must read the workflow state first, then the AI spec for AI tasks, verify actual GitHub truth, and continue from the exact unchecked item.

Required loop:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

## 10. CHECKPOINT RECORD

**Timestamp:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**HEAD:** `1eb7d5e5ef70e014842a601985ba791aafad7af5`
**Files changed during the documentation/specification update:**
- `AGENTS.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`

**Tests/checks:** documentation/specification changes only. No source-code behavior changed in this checkpoint. Historical native CI remains the latest verified code-level check.

**Result:** the Personal AI Browser Agent is now permanently part of WebLibre's product definition, including selectable/revocable permissions and an explicit user-granted Full Access mode.

**Exact next action:** finish the browser UA cold-start restore blocker; then perform UA/Proxy A-B isolation and targeted validation. After the stable browser milestone, begin AI-1 Browser Tool API.
