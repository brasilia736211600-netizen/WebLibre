# WebLibre Continuation Prompt — 2026-08-29

You are continuing an existing WebLibre Android browser project. Do not restart from scratch.

## Read first

1. `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
2. `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` when working on the AI track
3. `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md` for current project-level handoff
4. `AGENTS.md` for repository operating rules

Then verify the actual Git branch, HEAD, PR, CI, diff, and relevant source before editing.

## Repository rule

All work must remain in the intended user-controlled fork/branch. Preserve Git history. Never use `main` as scratch space. Do not rewrite unrelated history.

## Current browser state

The per-container UA data contract, normal/multi/duplicate creation propagation, session-level UA application before first navigation, and existing container settings UI are complete on the current feature branch.

Current blocker is cold-start/restored-tab UA because Android Components SessionStorage does not persist container UA in TabSessionState and native restore materializes sessions before Dart container metadata is available.

Next browser work:

1. solve pre-restore access to `contextId -> userAgent` with the smallest sound local mechanism;
2. apply UA before restored navigation;
3. test UA restore;
4. test Container A/B isolation;
5. verify proxy restore/A-B isolation;
6. run targeted validation;
7. stable APK milestone.

Do not redo completed creation paths.
Do not add global GeckoRuntime UA/proxy state.
Do not revive `_freshSnapshotPending` event-arrival heuristics.

## Personal AI Browser Agent — final product requirement

The final WebLibre product must include a dedicated personal AI Browser Agent. It is not the Acode AI Agent and not merely an OpenRouter/LLM integration.

The agent must:

- operate the real WebLibre browser through a controlled tool API;
- perform multi-step tasks using plan -> act -> observe -> continue loops;
- understand live tabs/pages/browser state;
- use containers, per-container UA, and per-container proxy correctly;
- have persistent owner-controlled profile and memory;
- remain model/provider independent;
- expose capabilities through explicit permissions chosen by the owner.

## Full permission model

The owner can grant complete capabilities at will, according to the task.

Permission scopes include, as applicable:

- read browser state;
- read page/content/screenshots;
- navigation;
- click/type/scroll interaction;
- tab lifecycle;
- downloads/files;
- authenticated sessions;
- container switching;
- proxy control;
- User-Agent control;
- browser settings;
- external communication/actions;
- other WebLibre-exposed capabilities.

Modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

Full Access is an explicit owner-selected grant for all currently exposed agent capabilities within the selected scope. Grants must support one-task, session, persistent, container-scoped and where useful site/domain-scoped lifetimes, plus immediate revoke and audit history.

The agent must never escalate its own permissions silently.

## Agent architecture

```text
Personal Agent UI
    -> Agent Core
    -> Permission Engine
    -> Browser Tool Registry
    -> WebLibre Browser API
    -> GeckoView / tabs / containers / page state
```

The LLM is not the authority for browser truth. WebLibre is authoritative for tool inputs/results and actual browser state.

Agent memory is separate from browser state and must be inspectable, editable, exportable, deletable, and disableable by the owner.

## AI implementation sequence

### AI-0 — specification
Complete. See `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

### AI-1 — Browser Tool API
Inventory existing WebLibre APIs and create the smallest internal tool registry. Every tool needs a schema, permission scope, side-effect declaration, and audit event.

### AI-2 — Agent Core
Implement task intake, context/observation builder, planning/reasoning adapter, tool loop, retry/timeouts, and stopping criteria.

### AI-3 — Personal Profile + Memory
Implement owner identity, instructions/preferences, short-term task memory, long-term reviewable memory, retention/delete controls, and data minimization.

### AI-4 — Permission Engine
Implement the selectable modes and task/session/persistent/container/site grants, Full Access, revocation, and audit history.

### AI-5 — First autonomous workflows
Research/extraction, navigation, multi-tab workflows, forms, container-aware tasks, and browser-approved file handling.

### AI-6 — Advanced personal behavior
Reusable workflows, user-specific conventions, permitted persistent context, self-checking, and common failure recovery.

### AI-7 — Model adapters
Provider-neutral interface, remote/local adapters, task-based model selection, privacy/cost policy, and context budgeting.

### AI-8 — Validation
Permission enforcement/revocation, memory controls, browser-state consistency, container UA/proxy isolation, unauthorized-action rejection, and end-to-end task completion.

## Candidate technology direction

Use Browser Use as the primary reference/candidate for agentic browser-control patterns. Use Stagehand and Skyvern as secondary references. Do not embed them as monoliths before defining the WebLibre internal tool boundary.

## Required engineering loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every meaningful checkpoint record:

- branch;
- HEAD;
- files changed;
- exact checks/results;
- blocker;
- exact next action.

## Immediate mission

Continue the first unchecked item from `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`. Finish the browser foundation first, then execute AI-1 onward. Do real work; do not merely describe the plan.
