# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `791969b4f89c9f1be2b8b1695c3a9f755bde671e`

## READ THIS FIRST

This is the project's durable execution memory. Do not reconstruct the project from chat history.

### Current canonical control documents
- `AGENTS.md` — current repository operating rules.
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md` — current execution state and exact next action.
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` — canonical personal AI Browser Agent specification.
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md` — current project handoff.
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md` — current continuation prompt.
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md` — current operating playbook.

The 2026-08-28 handoff/prompt/playbook files are historical references unless the current state explicitly reuses a detail.

## 1. FINAL PRODUCT

WebLibre has two dependent product tracks.

### Browser foundation
- independent Proxy per container;
- independent User-Agent per container;
- persistence/restoration;
- strict A/B isolation;
- final validation and APK.

### Personal AI Browser Agent
The final browser must include a dedicated personal AI agent for the owner/user. It must operate the real WebLibre browser through explicit browser tools, maintain user-controlled memory/profile, and remain model/provider independent.

This agent is **not** the Acode AI Agent and is **not** synonymous with OpenRouter or another LLM provider.

Canonical spec: `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

## 2. BROWSER WORK ALREADY COMPLETE

The active UA branch already contains:

- `ContainerMetadata.userAgent` persistence/serialization/equality/normalization;
- source Pigeon `AddTabParams.userAgent` contract;
- normal tab creation with per-container UA;
- multi-tab creation with authoritative container UA;
- duplicate-tab creation with container UA;
- native session-level UA before first navigation for those paths;
- existing container settings UI with UA field.

Do not redo these without evidence of regression.

## 3. CURRENT BROWSER BLOCKER — RESTORE

Verified restore path:

```text
SessionStorage
 -> RecoverableTab
 -> TabSessionState
 -> CreateEngineSessionMiddleware
 -> createSession(private, contextId)
 -> restoreState(engineSessionState)
```

Android Components SessionStorage does not serialize container UA in TabSessionState. Gecko session restore does not restore the separate session-level UA override.

Therefore the remaining browser task is to provide `contextId -> userAgent` to native restore before the first restored navigation.

### Exact next browser actions
1. Find the smallest sound native pre-restore persistence/lookup mechanism.
2. Apply the stored UA to the restored EngineSession before `restoreState()`/first navigation.
3. Add focused restore regression coverage.
4. Prove UA A/B isolation.
5. Verify Proxy restore/A-B isolation.
6. Run targeted validation.
7. Build stable debug APK.

Do not resurrect `_freshSnapshotPending` or other arrival-order heuristics.

## 4. PERSONAL AI AGENT — OFFICIAL PRODUCT WORKSTREAM

### Specification status
**COMPLETE.** The full requirement is in `WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.

### Core architecture

```text
Personal Agent UI
 -> Agent Core
 -> Permission Engine
 -> Browser Tool Registry
 -> WebLibre Browser API
 -> GeckoView / tabs / containers / page state
```

### Owner-only profile
The agent has a persistent personal profile containing explicit user instructions, preferences, workflows, trusted sites, memory policy, and permission configuration. Model/provider changes must not erase this identity or memory.

### User-controlled full permissions
The owner explicitly requested complete agent/browser capabilities as selectable permissions that can be granted according to the task.

Required capability families include:

- read browser state;
- read page/content/screenshots;
- navigation/search;
- click/type/scroll interaction;
- tab lifecycle;
- downloads/files;
- authenticated browser sessions when granted;
- container selection;
- proxy control;
- User-Agent control;
- browser settings;
- external communication/actions;
- other capabilities exposed by WebLibre.

Permission modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

`Full Access` is an explicit owner-selected grant for all currently exposed capabilities within the selected scope. Grants must support one-task, session, persistent, container-scoped, and optionally site/domain-scoped lifetimes, immediate revocation, and audit history.

The agent must never silently escalate its own permissions.

### Agent tool boundary
The model must never receive unrestricted direct access to internal WebLibre APIs. All browser actions go through an explicit, auditable tool registry with permission requirement, input/output schema, side-effect declaration, reversibility information, and confirmation category where configured.

### Memory
Memory is separate from browser state and must be user-controlled. The user must be able to inspect, edit, export, delete, or disable it. Arbitrary page content must not silently become permanent memory.

### Model strategy
The Agent Core is model/provider independent. Candidate references are Browser Use, Stagehand, and Skyvern; they are not committed dependencies.

## 5. AI ROADMAP

```text
AI-0 Specification                         [x]
AI-1 Browser Tool API                     [ ]  <- first AI implementation task after browser milestone
AI-2 Agent Core                           [ ]
AI-3 Personal Profile + Memory            [ ]
AI-4 Permission Engine                    [ ]
AI-5 First autonomous workflows           [ ]
AI-6 Advanced personal behavior           [ ]
AI-7 Model/provider adapters               [ ]
AI-8 End-to-end validation                [ ]
```

### AI-1 requirements
Inventory existing WebLibre browser APIs and implement the smallest internal Browser Tool Registry. Every tool must have an input/output schema, permission scope, side-effect declaration, reversibility metadata, and audit event.

Initial tool families: page/state reading, navigation/search, interaction, tabs, downloads/files, authenticated sessions, containers, proxy, UA, and browser settings.

### AI-2 requirements
Implement the plan/reason/act/observe loop, context builder, model adapter boundary, retries/timeouts, and stop conditions.

### AI-3 requirements
Implement owner profile, user instructions/preferences, short-term task memory, long-term reviewable memory, retention/deletion controls, and data minimization.

### AI-4 requirements
Implement all permission modes including Full Access, granular grants, scopes, revocation, and auditability.

### AI-5 requirements
First real workflows: research/extraction, multi-page navigation, forms, multi-tab tasks, container-aware tasks, and approved file handling.

## 6. FINAL PROJECT SEQUENCE

```text
BROWSER MILESTONE
UA restore
 -> UA A/B isolation
 -> Proxy restore/A-B verification
 -> targeted validation
 -> stable debug APK

AI MILESTONE
Browser Tool API
 -> Agent Core
 -> Permission Engine
 -> Personal Profile + Memory
 -> autonomous workflows
 -> model adapters/optimization
 -> end-to-end validation
 -> release APK
```

The AI agent must operate on top of the stable browser/container primitives, not bypass them.

## 7. GIT / PR / CI

- Active branch: `weblibre-ua-mainline-v3`.
- Current verified HEAD is the latest documentation checkpoint recorded at the top of this file.
- PR #3 is the active open/draft feature PR targeting `main`.
- Historical CI run `33265003957` passed native runtime prerequisites and Kotlin compilation.
- No claim of final CI success should be made until the post-change checks run on the current HEAD.

## 8. MANDATORY CONTINUATION LOOP

Always use:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

After every meaningful step update this file with:

- branch;
- HEAD;
- files changed;
- tests/checks and exact result;
- blocker;
- exact next action.

## 9. NEW-CHAT RESUME

A new agent should not ask the user to explain the project again.

Read:

1. `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`;
2. `AGENTS.md`;
3. `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` for AI work;
4. `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md` when project-level history is needed.

Then verify GitHub truth and continue from the exact next action.

## 10. CURRENT CHECKPOINT

**Timestamp:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Latest durable documentation commits:**
- `3059e18598ba723431c411b8a219861c5699672d` — personal AI specification added.
- `193aa5675943ee7d9452bf490631a9eda245952d` — current AGENTS rules updated.
- `e56d0c9a4116dc78fc9c3366c30c0277054af893` — current project handoff added.
- `e66b63b1fbebec444e219be79306a81e9d75c1a6` — current continuation prompt added.
- `791969b4f89c9f1be2b8b1695c3a9f755bde671e` — current operating playbook added.

**Current state file commit:** this checkpoint is being written after the latest documentation commits.

**Files changed by this documentation work:**
- `AGENTS.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT_2026-08-29.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK_2026-08-29.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`

**Tests/checks:** documentation/specification changes only; no source code changed in this checkpoint. Historical native CI remains the latest verified code check.

**Result:** the Personal AI Browser Agent is permanently defined as a final WebLibre product requirement, with owner-only identity, selectable/revocable permissions, and an explicit user-granted `Full Access` mode.

**Exact next action:** close the browser UA cold-start restore blocker; then verify UA/Proxy A/B isolation and targeted validation. After the stable browser milestone, start `AI-1 Browser Tool API`.
