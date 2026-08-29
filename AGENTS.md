# WebLibre Agent Operating Manual

## PURPOSE
This is an active engineering project. Continue the existing WebLibre implementation; do not rebuild it. The current execution memory is `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.

## MANDATORY FIRST ACTIONS
1. Read `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md` completely.
2. Read `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` when working on the AI-agent workstream.
3. Read the older handoff/playbook documents only when historical detail is needed; the 2026-08-29 workflow state supersedes stale claims.
4. Verify actual branch, HEAD, PR, CI, and current diff before editing.
5. Inspect exact source files and tests relevant to the task.

## REPOSITORY SAFETY
Reference repository: `https://github.com/brasilia736211600-netizen/WebLibre`

Work only in the intended feature branch/fork. Never use `main` as a scratch branch. Never force-push or rewrite unrelated history. Before modifying a file, inspect its current contents/blob SHA. Never overwrite generated files from partial snippets. If unrelated deletions appear, stop and repair them.

## USER'S ENGINEERING PRIORITIES
The user wants fast progress without wasting bandwidth or CI credits. Use YAGNI, minimal diffs, targeted validation, and atomic commits. Do not spend long cycles only describing future work.

Mandatory loop:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

After every meaningful checkpoint, update the durable workflow state with branch + HEAD + files changed + tests/results + blocker + exact next step.

## CURRENT PRODUCT
WebLibre has two dependent product tracks:

### Browser/privacy foundation
- Independent Proxy per container.
- Independent User-Agent per container.
- Per-container settings.
- Persistence/restoration.
- Strict A/B isolation.

### Personal AI Browser Agent
The final product must include a personal AI agent dedicated to the owner/user. This is not the Acode AI Agent and not an OpenRouter feature.

Canonical specification:
`docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

The agent must operate WebLibre through explicit browser tools, understand multi-step goals, observe live browser state, use containers/UA/proxy correctly, maintain user-controlled memory, and remain model/provider independent.

## PERSONAL AI AGENT — NON-NEGOTIABLE REQUIREMENTS
### Owner-controlled identity
The agent has a persistent personal profile containing explicit user instructions, preferences, workflows, trusted sites, memory policy, and permission configuration. Changing the model/provider must not erase this profile.

### Full permissions are selectable
The user explicitly wants complete agent/browser permissions available as options and grantable at will according to the task.

Permission scopes must include, as applicable:
- browser state read;
- page/content read;
- navigation;
- click/type/scroll interaction;
- tab lifecycle;
- downloads/files;
- authenticated sessions;
- container selection;
- proxy control;
- User-Agent control;
- browser settings;
- external communication/actions;
- other exposed sensitive capabilities.

Permission modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

`Full Access` grants all currently exposed agent capabilities within the selected scope when the owner explicitly chooses it. Grants must support one-task, session, persistent, container-scoped, and optionally site/domain-scoped lifetimes, plus immediate revocation and audit history.

The agent must never silently escalate its own permissions.

### Tool boundary
The LLM never receives unrestricted internal WebLibre APIs. All actions pass through a model-independent Browser Tool Registry with explicit schemas, required permissions, side-effect/reversibility metadata, and audit events.

### Memory/data control
Agent memory is separate from browser state and must be inspectable, editable, exportable, deletable, and disableable. Page content must not silently become permanent memory. Only data required for a particular inference should be sent to a model provider.

## UA CURRENT STATE
Already complete on the active UA branch:
- `ContainerMetadata.userAgent` data foundation;
- source Pigeon `AddTabParams.userAgent` contract;
- normal tab creation;
- multi-tab creation;
- duplicate-tab creation;
- session-level UA before first navigation;
- existing container UI field.

Current blocker: cold-start/restored-tab UA. Existing Android Components SessionStorage does not serialize container UA, and restore materialization occurs before Dart can supply container metadata. Do not redo completed creation paths. Do not add speculative arrival-order fixes to `syncEvents`.

## PROXY REQUIREMENT
Proxy remains per-container, never a global GeckoRuntime setting. Verify new sessions, restored sessions, concurrent A/B isolation, and fail-closed behavior where required by the existing routing snapshot design.

## RESTORE/EVENT FORENSICS
`syncEvents()` currently returns `Future<void>` without request/generation provenance. Tab-list events contain sequence information but not request attribution; stale debounced events may exist. `_freshSnapshotPending`-style arrival-order heuristics are UNSOUND. Only introduce explicit request/generation provenance if actual restore work proves it is required.

## AI IMPLEMENTATION ROADMAP
The personal AI track is intentionally downstream of the stable browser foundation:

### AI-0 Specification — COMPLETE
- [x] Owner-only agent concept.
- [x] Selectable/revocable permission model including Full Access.
- [x] Tool boundary.
- [x] Memory/data-control requirements.
- [x] Model/provider independence.

### AI-1 Browser Tool API — NEXT AFTER BROWSER MILESTONE
- [ ] Inventory existing WebLibre capabilities.
- [ ] Implement minimal internal Browser Tool Registry.
- [ ] Define stable input/output schemas.
- [ ] Attach permissions to every tool.
- [ ] Add audit events.

### AI-2 Agent Core
- [ ] Task intake and multi-step loop.
- [ ] Observation/context builder.
- [ ] Planner/reasoner adapter.
- [ ] Retry/timeouts/stop conditions.

### AI-3 Personal Profile + Memory
- [ ] Personal agent profile.
- [ ] Preferences/instructions.
- [ ] Short-term task memory.
- [ ] Long-term user-controlled memory.
- [ ] Data minimization.

### AI-4 Permission Engine
- [ ] Read Only.
- [ ] Browser Control.
- [ ] Task Control.
- [ ] Trusted Automation.
- [ ] Full Access.
- [ ] Task/session/persistent grants.
- [ ] Container/site scopes.
- [ ] Revocation.
- [ ] Audit history.

### AI-5 First autonomous workflows
- [ ] Research/extraction.
- [ ] Multi-page navigation.
- [ ] Form completion under granted permissions.
- [ ] Multi-tab workflows.
- [ ] Container-aware workflows.
- [ ] Browser-approved file handling.

### AI-6 Advanced behavior
- [ ] Reusable workflows.
- [ ] User-specific conventions.
- [ ] Persistent browser context where permitted.
- [ ] Self-checking against user rules.
- [ ] Common-failure recovery.

### AI-7 Model adapters
- [ ] Provider-neutral interface.
- [ ] Remote model adapters.
- [ ] Local model adapters where feasible.
- [ ] Task-based model selection/privacy/cost policy.
- [ ] Context/token budgeting.

### AI-8 End-to-end validation
- [ ] Permission enforcement/revocation tests.
- [ ] Memory isolation tests.
- [ ] Browser-state consistency tests.
- [ ] Agent + container UA/proxy isolation.
- [ ] Unauthorized action rejection.
- [ ] End-to-end task completion.

## CANDIDATE TECHNOLOGY DIRECTION
Browser Use is the primary reference/candidate for agentic browser-control architecture; Stagehand and Skyvern are secondary references. Do not embed a candidate blindly. Define the internal WebLibre Browser Tool API first, then benchmark adapters against the actual GeckoView/Android constraints.

## VALIDATION / BUILD DISCIPLINE
Preferred order:

1. Focused tests.
2. `flutter analyze`.
3. Targeted Kotlin/native checks.
4. Pigeon generation consistency when the source contract changes.
5. Targeted integration/build.
6. Full APK only at a stable milestone.

Do not repeatedly consume CI/network budget on full APK builds for narrow changes.

## NON-NEGOTIABLE INVARIANTS
1. UA is per container/session, never global.
2. Proxy is per container, never silently global.
3. Container A cannot mutate Container B.
4. UA is applied before first navigation.
5. Restore preserves UA/proxy policy.
6. Event arrival order is not request/response provenance.
7. Prefer local WebLibre integration over upstream dependency forks.
8. Generated code remains synchronized with its source.
9. Targeted validation precedes expensive builds.
10. Agent capabilities never exceed the currently granted permissions.
11. User can explicitly grant/revoke Full Access.
12. Agent memory and identity are user-controlled.

## REPORTING
Every meaningful report/checkpoint must include:
- branch;
- HEAD;
- files changed;
- tests/checks and exact result;
- blocker;
- exact next action.

Never claim runtime completion from a data model alone.
