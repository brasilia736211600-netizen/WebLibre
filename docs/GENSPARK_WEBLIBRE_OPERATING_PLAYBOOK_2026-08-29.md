# WebLibre Operating Playbook — 2026-08-29

## Canonical control files

Use these in every new engineering session:

1. `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md` — execution memory and exact next action.
2. `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` — final Personal AI Browser Agent product specification.
3. `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md` — current project handoff.
4. `AGENTS.md` — repository operating rules.

Older 2026-08-28 documents are historical unless the current workflow state explicitly reuses a detail.

## Golden rule

Do not make a new agent rediscover project history from chat. Read the durable state, verify Git truth, then continue from the first unchecked item.

## Engineering loop

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

Every meaningful checkpoint must record branch, HEAD, files changed, tests/results, blocker, and exact next action.

## Current browser milestone

Finish:

`UA restore -> UA A/B isolation -> proxy restore/A-B verification -> targeted validation -> stable debug APK`

Do not redo the completed UA model/Pigeon/normal/multi/duplicate/UI work unless a regression is demonstrated.

## Personal AI Browser Agent

The final product must contain a personal AI Browser Agent operating the real WebLibre browser. It is not the Acode AI Agent and not an LLM-provider feature.

Required architecture:

`Personal Agent UI -> Agent Core -> Permission Engine -> Browser Tool Registry -> WebLibre Browser API -> GeckoView`

The agent is personal to the owner and has persistent, user-controlled instructions, preferences, workflows, and memory.

## Permission strategy

All meaningful browser capabilities are explicit permissions. The owner can grant or revoke them according to the current task.

Modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

Full Access is an explicit owner-selected grant for all capabilities currently exposed by WebLibre within the selected scope. Support one-task, session, persistent, container-scoped, and optionally site/domain-scoped grants. Support immediate revocation and audit history.

The agent cannot silently grant itself more permissions.

## Required tool boundary

Do not expose arbitrary internal WebLibre APIs to the model. Build a stable tool registry. Initial tool families cover:

- browser/page reading;
- navigation/search;
- interaction;
- tabs;
- downloads/files;
- authenticated sessions where granted;
- container selection;
- proxy and UA controls;
- browser settings;
- external actions.

Each tool declares permission scope, input/output schema, side effects, reversibility, and audit metadata.

## Memory and data policy

Separate browser state, agent context, model requests, and persistent memory.

The owner must be able to inspect, edit, export, clear, or disable agent memory. Do not silently persist arbitrary page content. Send only task-required data to the selected model provider.

## Technology evaluation

Browser Use is the primary reference candidate for agentic browser control. Stagehand and Skyvern are secondary references. Do not blindly embed any candidate. First define the WebLibre internal tool API, then create an adapter/benchmark layer.

## AI roadmap

`AI-0 specification [x]`

`AI-1 Browser Tool API [ ]`

`AI-2 Agent Core [ ]`

`AI-3 Personal Profile + Memory [ ]`

`AI-4 Permission Engine [ ]`

`AI-5 First autonomous workflows [ ]`

`AI-6 Advanced personal behavior [ ]`

`AI-7 Model adapters [ ]`

`AI-8 End-to-end validation [ ]`

## Low-credit strategy

Prefer source inspection and targeted tests. Do not run a full APK build for a narrow failure. Do not upload the whole repository to a context hub. Use the canonical docs plus direct repository inspection.

## Parallelism

Parallelize only independent work. Never have two agents modify the same source/Pigeon/generated/workflow file concurrently.

## Final product sequence

```text
Browser foundation
  -> stable APK
  -> Browser Tool API
  -> Agent Core
  -> Permission Engine
  -> Personal Profile + Memory
  -> autonomous workflows
  -> model adapters
  -> end-to-end validation
  -> release
```

## New-chat rule

A new chat should require no project re-explanation. Read `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`, verify actual GitHub state, read the AI spec when working on the agent, and continue from the exact next action.
