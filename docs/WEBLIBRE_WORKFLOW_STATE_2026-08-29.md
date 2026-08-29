# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `3059e18598ba723431c411b8a219861c5699672d`

## Purpose — READ THIS FIRST

This is the project's **durable execution memory**.

A new AI agent must read this file before doing implementation work. It must not reconstruct the project from chat history when the repository already contains the facts.

The canonical supporting documents are:

- `AGENTS.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` **(new canonical product/architecture specification for the personal AI Browser Agent)**
- this file: `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`

**Source-of-truth rule:** actual current Git state, current source code, current CI evidence, and the newest update to this file override stale claims in older handoff documents.

**Persistence rule:** after every meaningful implementation/checkpoint, update this file with the new branch/HEAD, files changed, tests/checks, result, and exact next step. Do not leave the durable state describing an obsolete stage.

---

## 1. Final product objective

WebLibre is being developed toward two integrated goals:

### A. Privacy-oriented browser foundation

1. independent proxy per container;
2. independent User-Agent per container;
3. persistence/restoration;
4. strict A/B isolation;
5. minimal changes to the existing architecture;
6. final validation and APK.

### B. Personal AI Browser Agent

The final browser must include a **dedicated personal AI agent** that can operate WebLibre itself through explicit browser tools and the user's selected permissions.

This is **not** the Acode AI Agent project and **not** merely an OpenRouter integration.

The agent must be able to:

- understand a user goal;
- inspect the live browser state;
- operate tabs/pages/navigation/forms/files through a controlled tool API;
- perform multi-step tasks and re-observe results;
- use the existing container/Proxy/UA identity correctly;
- maintain user-controlled memory and preferences;
- operate under explicit, revocable permission grants;
- support a `Full Access` capability mode when the owner chooses it;
- remain model/provider independent.

Canonical specification:

`docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

---

## 2. Current verified status — browser/container work

### UA data foundation — COMPLETE

- `ContainerMetadata` contains `String? userAgent`.
- persistence/serialization/`copyWith`/equality/normalization are implemented;
- model tests were added and passed in the earlier implementation cycle.

### UA Pigeon contract — COMPLETE

`packages/flutter_mozilla_components/pigeons/gecko.dart` currently carries `userAgent` through the existing tab-creation contract (`AddTabParams`). Do not add the same field again.

### Native per-session UA — COMPLETE for verified creation paths

`GeckoEngineSession.settings.userAgentString` maps to GeckoView's session-level `userAgentOverride`.

Creation ordering is:

```text
create EngineSession
  -> set session UA
  -> create/use tab state with prepared session
  -> AddTabAction
  -> first LoadUrlAction
```

### Tab creation variants — COMPLETE at code level

Covered:

- normal `addTab`;
- `addMultipleTabs` with destination-container UA authoritative;
- `duplicateTab` using the container UA.

### Container settings UI — COMPLETE at code level

The existing container edit UI has a User-Agent field persisted through `ContainerMetadata`.

### Historical native CI — VERIFIED GREEN

Workflow run `33265003957` successfully completed the native runtime prerequisites and Android Kotlin compilation. The temporary verification workflow was removed afterward.

---

## 3. Current Git / PR / CI reconciliation

- `weblibre-p0-container-restore` remains a separate historical/earlier branch at `87b450ed584a3f81bb37a4cc4261e7a553d164fa`.
- Active feature branch: `weblibre-ua-mainline-v3`.
- Current HEAD after durable AI-agent specification commit: `3059e18598ba723431c411b8a219861c5699672d`.
- PR #3 is the active feature PR, open/draft, base `main`, head `weblibre-ua-mainline-v3`.
- The latest known PR head is the current branch HEAD.
- No new CI status has been reported for the latest documentation/specification commits yet.

Do not silently switch back to the P0 branch.

---

## 4. Current engineering blocker — UA restore

The verified restore path is:

```text
restoreTabsByList()
  -> GeckoTabsApi.restoreTabsByList(...)
  -> Pigeon RecoverableTab
  -> Android Components RecoverableTab
  -> TabsUseCases.RestoreUseCase
  -> TabListAction.RestoreAction
  -> RecoverableTab.toTabSessionState()
  -> TabSessionState
  -> EngineAction.CreateEngineSessionAction
  -> engine.createSession(private, contextId)
  -> engineSession.restoreState(engineSessionState)
```

### Materialization finding — VERIFIED

The inspected Android Components implementation shows:

- restored EngineSession creation uses `TabSessionState.private/contextId`;
- `GeckoEngineSession.restoreState()` delegates to `GeckoSession.restoreState()`;
- session-level UA is a separate setting and is not encoded in the existing `TabSessionState`/`SessionStorage` contract.

Therefore the current cold-start restore cannot recover per-container UA merely from the existing session snapshot.

### Current decision

Do not add a speculative Pigeon `RecoverableTab.userAgent` field by itself. It would not fix native cold-start restore.

Next browser task:

1. identify the smallest native pre-restore persistence/lookup mechanism for `contextId -> userAgent`;
2. apply it to restored EngineSessions before `restoreState()` / first restored navigation;
3. add focused restore regression coverage;
4. prove A/B UA isolation;
5. run targeted validation.

Do not reopen the separate `syncEvents` provenance investigation unless restore implementation actually requires it.

---

## 5. Proxy workstream

Proxy remains a separate per-container requirement.

Required final verification:

```text
Container A -> Proxy-A
Container B -> Proxy-B
changing A -> B remains Proxy-B
restore preserves proxy policy
```

Do not collapse proxy state into a global GeckoRuntime setting.

---

## 6. Personal AI Browser Agent — NEW PRIMARY PRODUCT WORKSTREAM

### Status

**Specification: COMPLETE. Implementation: NOT STARTED.**

Canonical spec:

`docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

### Product requirements

The Personal AI Browser Agent must be a first-class part of WebLibre, not an external chatbot.

Architecture:

```text
User
  -> Personal Agent UI
  -> Agent Core
  -> Permission Engine
  -> Tool Registry
  -> WebLibre Browser API
  -> GeckoView / tabs / containers / page state
```

### Owner-only identity

The agent is intended for one owner/user and has a persistent Personal Agent Profile containing user instructions, preferences, workflows, trusted sites, memory policy, and permission configuration.

Changing the LLM/provider must not erase the agent identity or memory.

### User-controlled full permissions

The user explicitly requires that **full agent/browser permissions be selectable and grantable at will, according to the task**.

The permission engine must support at least:

- browser-state read;
- page-content read;
- navigation;
- interaction/input;
- tab lifecycle;
- downloads/files;
- authenticated browser sessions;
- container switching;
- proxy use/change;
- User-Agent use/change;
- browser settings;
- external communication/actions;
- other sensitive actions exposed by WebLibre.

Permission modes:

```text
Read Only
Browser Control
Task Control
Trusted Automation
Full Access
```

`Full Access` grants all currently exposed agent capabilities within the selected scope when the owner chooses it.

Every grant must support explicit scope and revocation, including one-task, session, persistent, container-scoped, and optionally site/domain-scoped grants.

The agent must never silently escalate its own permissions.

### Agent tool boundary

The model must never receive unrestricted direct access to internal WebLibre APIs. All browser actions go through an explicit, auditable tool registry with:

- permission requirement;
- input/output schema;
- side-effect declaration;
- reversibility information;
- confirmation category when configured.

Initial tool families include navigation, page inspection, interaction, tabs, downloads/files, containers, proxy, and UA operations. The complete contract is in the canonical AI-agent spec.

### Memory

Memory is separate from browser state and must be user-controlled. It includes preferences, recurring workflows, trusted sites, task conventions, short-term task memory, and long-term memory.

The user must be able to inspect, edit, export, delete, or disable agent memory.

### Model strategy

The Agent Core is model/provider independent. The project must not hardwire the architecture to OpenRouter, Acode AI Agent, or any single vendor.

Current technology candidates are references only:

1. Browser Use — primary candidate/reference for agentic browser-control architecture.
2. Stagehand — reference for deterministic + AI browser actions.
3. Skyvern — reference for autonomous multi-step/visual browser workflows.

Do not embed any of these blindly. First define the WebLibre Browser Tool API and adapter boundary, then benchmark candidates against the actual WebLibre/Android constraints.

### AI implementation roadmap

```text
AI-0  Specification                         [x]
AI-1  WebLibre Browser Tool boundary       [ ]
AI-2  Agent Core                           [ ]
AI-3  Personal Profile + Memory            [ ]
AI-4  Permission Engine                    [ ]
AI-5  First autonomous browser workflows   [ ]
AI-6  Advanced personal behavior           [ ]
AI-7  Model/provider adapters               [ ]
AI-8  End-to-end validation                [ ]
```

### Final AI-agent Definition of Done

- [ ] dedicated Personal Agent Profile;
- [ ] stable internal Browser Tool API;
- [ ] multi-step browser task loop;
- [ ] persistent user-controlled memory;
- [ ] explicit capability permissions;
- [ ] user-selectable Full Access mode;
- [ ] task/session/persistent permission grants;
- [ ] immediate revocation;
- [ ] container/site scoping where applicable;
- [ ] auditability of agent actions/grants;
- [ ] correct use of per-container UA and Proxy;
- [ ] no capability beyond current grants;
- [ ] model/provider replaceability;
- [ ] end-to-end tasks working on the actual WebLibre browser.

---

## 7. Final project completion sequence

The project should now be treated as two dependent milestones, not one blended implementation task:

```text
MILESTONE A — Browser foundation

UA restore
  -> UA A/B isolation
  -> Proxy regression/restore
  -> targeted tests/analyze/native validation
  -> stable debug APK

MILESTONE B — Personal AI Browser

Browser Tool API
  -> Agent Core
  -> Permission Engine
  -> Personal Profile + Memory
  -> first autonomous workflows
  -> model adapters/optimization
  -> end-to-end validation
  -> final release
```

The Agent must use the completed browser/container primitives instead of bypassing them.

---

## 8. YAGNI / non-negotiable rules

Do not:

- redo completed UA creation/UI work;
- add a global GeckoRuntime UA or proxy;
- add a Pigeon field without source proof that it is required;
- resurrect `_freshSnapshotPending` arrival-order heuristics;
- introduce a second container metadata store unnecessarily;
- embed Browser Use/Stagehand/Skyvern as a monolith before defining the internal tool boundary;
- couple the Agent Core permanently to one model/provider;
- grant the agent unrestricted access without the explicit permission system;
- start full APK builds before cheaper targeted checks pass.

Always use:

```text
READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE
```

After every meaningful step update:

- branch + HEAD;
- files changed;
- tests/checks + exact result;
- current blocker;
- exact next action.

---

## 9. New-chat resume procedure

A new coding agent should do this without asking the user to re-explain the project:

1. Read `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
2. Read `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` when working on the AI track.
3. Verify actual branch/HEAD/PR/CI.
4. Treat this workflow-state file as the current execution memory.
5. Never redo an `[x]` item unless evidence shows a regression.
6. Continue from the exact unchecked item recorded here.

Suggested resume prompt:

```text
@GitHub @Thinking
استأنف مشروع WebLibre من docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md.
هذا الملف هو الذاكرة التنفيذية الأساسية.
تحقق من branch وHEAD وPR وCI والحالة الفعلية قبل أي تعديل.
لا تعِد أي عمل معلّم كمكتمل إلا بدليل regression.
استخدم YAGNI وأصغر تغيير ممكن.
تابع من Exact next action ونفّذها مباشرة.
بعد كل خطوة مهمة حدّث الملف نفسه بالـbranch والـHEAD والملفات والاختبارات والنتيجة والخطوة التالية.
```

---

## 10. History / corrections

### 2026-08-29 — UA restore correction

The restore materialization path is now proven. Existing Android Components SessionStorage does not preserve per-container UA, and native cold-start restore occurs before Dart container metadata can be supplied.

### 2026-08-29 — Personal AI Agent promoted to final-product requirement

The personal AI Browser Agent is now an official WebLibre product workstream.

It is not synonymous with Acode AI Agent or an LLM provider. The required architecture is a model-independent browser-operating agent with an explicit WebLibre Tool API, owner-controlled memory, and selectable/revocable permissions including a user-granted `Full Access` mode.

The canonical detailed specification is:

`docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

This requirement must survive future chat/session changes and must not be forgotten or treated as optional polish.
