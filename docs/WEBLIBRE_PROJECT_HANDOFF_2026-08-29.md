# WebLibre — Master Project Handoff 2026-08-29

## Current source of truth

- Repository: `brasilia736211600-netizen/WebLibre`
- Active branch: `weblibre-ua-mainline-v3`
- Durable execution state: `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- Personal AI Agent specification: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- Older 2026-08-28 handoff: historical reference only where it does not conflict with the current workflow state.

## Product goal

WebLibre is an existing Flutter/Android GeckoView browser being extended into a privacy-oriented browser with per-container network/browser identity and a first-class personal AI Browser Agent.

Do not rebuild the browser from scratch.
Do not turn container identity into global GeckoRuntime state.

## Browser/container status

### Complete

- Container metadata supports optional `userAgent`.
- UA persistence/serialization/equality/normalization.
- UA tab-creation contract.
- Normal new-tab UA propagation.
- Multiple-tab UA propagation.
- Duplicate-tab UA propagation.
- Native session-level UA before first navigation for those creation paths.
- Existing container UA settings UI.

### Still required

- Cold-start/restored-tab UA before first restored navigation.
- UA A/B runtime isolation test.
- Proxy runtime/restore regression and A/B isolation verification.
- Final targeted validation and milestone APK.

## Restore finding

The current Android Components restore pipeline is:

`SessionStorage -> RecoverableTab -> TabSessionState -> CreateEngineSessionMiddleware -> createSession(contextId) -> restoreState(engineSessionState)`

The existing Android Components SessionStorage contract does not persist container UA in `TabSessionState`. A Pigeon-only `RecoverableTab.userAgent` change would therefore not solve native cold-start restoration by itself.

Do not use event-arrival heuristics to pretend that `syncEvents()` identifies its own tab-list response. The previously proposed `_freshSnapshotPending` approach is rejected as unsound.

## Personal AI Browser Agent

This is an official final-product requirement, not optional polish.

The agent is:

- personal to the owner/user;
- persistent through an owner-controlled profile;
- capable of multi-step browser operations;
- model/provider independent;
- connected to WebLibre through a controlled Browser Tool API;
- able to use current WebLibre tabs, pages, containers, proxy, UA and approved files;
- governed by explicit, revocable permissions.

It is not the Acode AI Agent and not synonymous with OpenRouter or any LLM provider.

Canonical specification:

`docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

## Permission model

The user explicitly wants complete agent capabilities available as selectable options that can be granted at will and according to the task.

Required permission scopes include browser-state read, page/content read, navigation, interaction, tabs, downloads/files, authenticated sessions, containers, proxy, UA, browser settings, external communications/actions, and other capabilities exposed by WebLibre.

Required modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

`Full Access` is an explicit owner grant for all currently exposed agent capabilities within the selected scope. Grants support one-task, session, persistent, container-scoped, and where useful site/domain-scoped lifetimes. Revocation is immediate. The agent cannot silently escalate itself.

## Agent architecture

```text
Personal Agent UI
  -> Agent Core
  -> Permission Engine
  -> Browser Tool Registry
  -> WebLibre Browser API
  -> GeckoView / tabs / containers / page state
```

Memory is separate from browser state and user-controlled. The user can inspect, edit, export, clear or disable it.

The model is a reasoning component. WebLibre remains authoritative for actual browser state and tool results.

## AI roadmap

### AI-0 — Specification
- [x] Personal-agent product requirement.
- [x] Owner identity/profile requirements.
- [x] Selectable/revocable permissions including Full Access.
- [x] Browser Tool boundary.
- [x] Memory and data-routing requirements.

### AI-1 — Browser Tool API
- [ ] Inventory current WebLibre APIs.
- [ ] Create minimal internal tool registry.
- [ ] Define stable schemas.
- [ ] Attach permission scopes.
- [ ] Add audit events.

### AI-2 — Agent Core
- [ ] Task intake.
- [ ] Plan/reason/act/observe loop.
- [ ] Retry/timeouts/stop criteria.
- [ ] Provider-neutral model adapter.

### AI-3 — Personal Profile + Memory
- [ ] Persistent owner profile.
- [ ] Preferences/instructions.
- [ ] Short-term task memory.
- [ ] Long-term user-controlled memory.
- [ ] Data minimization and retention controls.

### AI-4 — Permission Engine
- [ ] Permission modes.
- [ ] Task/session/persistent grants.
- [ ] Container/site scopes.
- [ ] Full Access.
- [ ] Revocation.
- [ ] Audit history.

### AI-5 — First autonomous workflows
- [ ] Research/extraction.
- [ ] Multi-page tasks.
- [ ] Forms.
- [ ] Multi-tab workflows.
- [ ] Container-aware tasks.
- [ ] Approved file handling.

### AI-6 — Advanced personal behavior
- [ ] Reusable workflows.
- [ ] User-specific conventions.
- [ ] Persistent context where permitted.
- [ ] Recovery from common failures.

### AI-7 — Model adapters
- [ ] Provider-neutral interface.
- [ ] Remote models.
- [ ] Local models where practical.
- [ ] Task-based model/privacy/cost selection.

### AI-8 — End-to-end validation
- [ ] Permission enforcement.
- [ ] Revocation.
- [ ] Memory controls.
- [ ] Agent/browser-state consistency.
- [ ] UA/proxy/container isolation.
- [ ] Autonomous end-to-end tasks.

## Technology direction

Current candidate/reference projects:

- Browser Use — primary reference/candidate for agentic browser-control architecture.
- Stagehand — reference for deterministic + AI browser actions.
- Skyvern — reference for more autonomous/visual workflows.

Do not embed any candidate blindly. Define WebLibre's Browser Tool API first, then benchmark adapters against GeckoView/Android and device constraints.

## Release path

```text
UA restore
 -> UA A/B isolation
 -> Proxy hardening/A-B verification
 -> targeted validation
 -> stable debug APK
 -> Browser Tool API
 -> Agent Core
 -> Permission Engine + Personal Profile/Memory
 -> autonomous workflows
 -> model adapters/optimization
 -> end-to-end validation
 -> release APK
```

## Mandatory continuation rule

A new AI agent must read the 2026-08-29 workflow state first, verify actual Git state, and continue from the first unchecked item. Never redo completed work without evidence of regression.
