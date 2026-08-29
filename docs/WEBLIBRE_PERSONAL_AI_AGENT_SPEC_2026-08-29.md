# WebLibre — Personal AI Browser Agent Specification

**Date:** 2026-08-29
**Status:** Product requirement and architecture plan; implementation starts after the current UA/restore milestone.

## Product and release requirements

WebLibre's final product includes the Personal AI Browser Agent defined below. The final Android release must also provide independently downloadable ABI-specific APK artifacts rather than requiring the user to download one bundled universal APK. Supported ABI outputs such as `arm64-v8a`, `armeabi-v7a`, and `x86_64` must be published separately when built/supported. The release build should use ABI split packaging such as `flutter build apk --split-per-abi`.

## Product goal

WebLibre is intended to become a privacy-oriented Android browser with a **personal AI Browser Agent** dedicated to the owner/user.

This is NOT:
- a generic chatbot attached to a browser;
- an Acode coding agent;
- an OpenRouter-specific feature;
- a single fixed LLM vendor integration.

The target is an actual browser-operating agent that can understand a user goal, inspect the live WebLibre state, use browser tools, perform multi-step actions, observe results, recover from ordinary failures, and finish the task according to the user's instructions.

Core model:

```text
User goal
  -> Personal Agent Core
  -> planning/reasoning loop
  -> browser tools
  -> WebLibre live browser state
  -> action/result
  -> re-observe
  -> next action
  -> completion
```

## Personal/private identity

The agent is intended for one owner/user. It should have a persistent **Personal Agent Profile** containing the owner's explicit instructions, preferences, workflows, trusted sites, memory policy, and permission grants.

The agent identity must be separable from the model provider. Changing the underlying model must not erase the user's agent profile or memory.

The architecture should support an owner-controlled local identity boundary, with optional device authentication/lock before granting sensitive capabilities.

Do not silently upload all browser data to a model/provider. Data access must follow the permission and data-routing policy selected by the user.

## Full permissions — user-controlled and revocable

The user explicitly requested that the agent be capable of **full browser permissions as selectable options**, granted only when the user chooses and according to the task.

Therefore implement a permission system with:

### Permission scopes

- `read_browser_state`: tabs, current tab, page state, navigation state.
- `read_page_content`: DOM/accessibility tree, visible text, page metadata, screenshots where supported.
- `navigate`: open URLs, search, back/forward/reload.
- `interact`: click, type, select, scroll, keyboard actions.
- `tabs`: create, switch, duplicate, close, reorder.
- `downloads`: start, monitor, cancel, and manage browser downloads.
- `files`: access browser-approved files/directories required by a task.
- `accounts_and_sessions`: use already authenticated browser sessions where the user grants access.
- `containers`: select/switch containers and use their configured identity.
- `proxy`: use or modify container proxy settings when explicitly granted.
- `user_agent`: use or modify container UA settings when explicitly granted.
- `browser_settings`: modify selected browser settings.
- `external_communication`: send messages/forms/posts/emails through sites when granted.
- `sensitive_actions`: actions with material side effects, which must be individually grantable.

### Permission modes

Provide selectable modes rather than one hidden all-or-nothing behavior:

```text
Read Only
Browser Control
Task Control
Trusted Automation
Full Access
```

`Full Access` means all capabilities currently exposed by WebLibre are granted to the agent for the selected scope/session, subject to explicit user revocation and any separate confirmation rule the user has configured.

Permissions must support:

- one-task grants;
- session grants;
- persistent grants;
- container-scoped grants;
- site/domain-scoped grants where useful;
- immediate revoke;
- visible current-grant status;
- audit history of grants and agent actions.

The user can change permission level at any time.

## Safety and control model

The agent should never silently escalate its own permissions.

The permission engine must be explicit about:

```text
Requested capability
Current grant
Scope
Reason/task
Whether a confirmation is required
```

User-configured confirmation behavior should be supported so the owner can choose which categories require approval and which are pre-authorized.

A task should be able to request a temporary elevated grant without changing the user's permanent policy.

## Browser Tool API

Create a model-independent internal tool registry. Initial tool families:

```text
open_url
search
read_page
inspect_page
screenshot
click
click_by_text
click_by_role
type_text
select_option
scroll
press_key
back
forward
reload
wait
find_in_page
create_tab
switch_tab
close_tab
duplicate_tab
get_tabs
get_current_tab
get_downloads
start_download
read_file
write_file
select_container
get_container
get_container_settings
set_container_proxy
set_container_user_agent
```

Every tool must declare:

- required permission scope;
- input schema;
- output schema;
- whether it has side effects;
- whether it is reversible;
- optional confirmation category.

Do not expose unrestricted internal application APIs directly to the model. Put them behind an explicit tool boundary.

## Agent Core

The Agent Core is responsible for:

1. task intake;
2. context construction;
3. planning;
4. tool selection;
5. tool invocation;
6. observation processing;
7. state tracking;
8. retry/recovery;
9. stopping criteria;
10. user-facing progress/results.

It must be model-agnostic.

The LLM is a reasoning component, not the browser authority. WebLibre remains the source of truth for actual browser state and tool results.

## Personal memory

Implement memory as a separate layer with explicit categories:

- user preferences;
- recurring workflows;
- trusted sites/domains;
- task conventions;
- learned but user-reviewable facts;
- short-term task memory;
- long-term personal memory.

Memory must have retention/deletion controls and must not silently turn arbitrary page content into permanent user memory.

The user should be able to inspect, edit, export, clear, or disable agent memory.

## Data routing

The architecture must separate:

```text
browser-local data
agent context
model request
persistent memory
```

Only the data necessary for the current inference should be sent to a model provider.

The project should support multiple model backends later, including remote and local models. Do not couple the agent architecture to one provider.

## Candidate technology direction

Initial technology evaluation should include:

1. **Browser Use** as the primary reference implementation/candidate for agentic browser control because it is explicitly designed to connect AI agents to browsers and is open source. Validate whether its execution model can be adapted to WebLibre instead of replacing the native GeckoView browser.
2. **Stagehand** as an alternative reference for combining deterministic browser actions with AI-driven `act/observe/extract` patterns.
3. **Skyvern** as a reference for more autonomous multi-step browser workflows and visual interaction; evaluate especially its architecture rather than assuming its Chromium/cloud execution model fits Android.

Current decision: **do not embed any candidate blindly**. First define WebLibre's internal Browser Tool API and adapter boundary, then benchmark candidates against it.

## Recommended architecture

```text
                  ┌────────────────────────┐
                  │   Personal Agent UI    │
                  │ task / grants / status │
                  └────────────┬───────────┘
                               │
                  ┌────────────▼───────────┐
                  │     Agent Core         │
                  │ plan / reason / act    │
                  └───────┬─────────┬──────┘
                          │         │
                 ┌────────▼───┐ ┌─▼─────────────┐
                 │ Tool Registry│ │ Memory Store │
                 └───────┬────┘ └───────────────┘
                         │
                 ┌───────▼───────────────┐
                 │ Permission Engine     │
                 │ scope / grant / audit │
                 └───────┬───────────────┘
                         │
                 ┌───────▼───────────────┐
                 │ WebLibre Browser API  │
                 └───────┬───────────────┘
                         │
          ┌──────────────▼───────────────────┐
          │ GeckoView / tabs / containers    │
          │ page state / proxy / UA / files  │
          └───────────────────────────────────┘
```

## Implementation phases

### AI-0 — specification
- [x] Add this specification to the durable project docs.
- [x] Define owner-only agent identity.
- [x] Define selectable/revocable full permissions.
- [x] Define browser-tool boundary.
- [x] Define model-independent architecture.
- [x] Define independent ABI APK release artifacts.

### AI-1 — Browser Tool boundary
- [ ] Inventory the existing WebLibre APIs that can support agent tools.
- [ ] Create the minimal internal tool registry.
- [ ] Define stable input/output schemas.
- [ ] Map each tool to permission scopes.
- [ ] Add tool-level audit events.

### AI-2 — Agent Core
- [ ] Create the task loop.
- [ ] Add observation/context builder.
- [ ] Add planner/reasoner adapter.
- [ ] Add retry/timeout/stop controls.
- [ ] Keep model provider independent.

### AI-3 — Personal Profile + Memory
- [ ] Owner profile.
- [ ] User instructions/preferences.
- [ ] Short-term task memory.
- [ ] Long-term memory with review/delete controls.
- [ ] Data minimization rules.

### AI-4 — Permission Engine
- [ ] Read-only mode.
- [ ] Browser-control mode.
- [ ] Task-control mode.
- [ ] Trusted automation mode.
- [ ] Full Access mode.
- [ ] Per-task/session/persistent grants.
- [ ] Container/site scoping.
- [ ] Revocation.
- [ ] Audit history.

### AI-5 — First agent workflows
- [ ] Research and summarize.
- [ ] Navigate a website and collect structured information.
- [ ] Fill a form using user-provided rules.
- [ ] Work across multiple tabs.
- [ ] Use different containers according to task instructions.
- [ ] Download and organize browser-approved files.

### AI-6 — Advanced personal behavior
- [ ] Reusable workflows.
- [ ] User-specific task conventions.
- [ ] Persistent browser context where permitted.
- [ ] Agent self-checking against user rules.
- [ ] Recovery from common navigation failures.

### AI-7 — Provider/model adapters
- [ ] Provider-neutral interface.
- [ ] Remote model adapter(s).
- [ ] Local model adapter(s) where device constraints permit.
- [ ] Model selection policy by task complexity/cost/privacy.
- [ ] Context/token budgeting.

### AI-8 — Validation
- [ ] Tool permission tests.
- [ ] Memory isolation tests.
- [ ] Agent-vs-browser state consistency tests.
- [ ] A/B container isolation with the agent.
- [ ] Unauthorized action rejection tests.
- [ ] Revocation tests.
- [ ] End-to-end task completion tests.
- [ ] Verify each supported ABI APK is independently installable/downloadable.

## Integration with current Container Privacy work

The agent must be able to use the browser's existing container identity rather than bypassing it.

Required invariant:

```text
Agent task
  -> select Container A
  -> WebLibre uses UA-A + Proxy-A

same agent
  -> select Container B
  -> WebLibre uses UA-B + Proxy-B

A must not mutate B.
```

Container/UA/proxy work therefore remains a prerequisite for the agent's reliable privacy-aware browsing behavior.

## Definition of Done — Personal AI Browser Agent

The final product is not complete until:

- [ ] a dedicated personal agent profile exists;
- [ ] browser tools are implemented behind a stable API;
- [ ] the agent can perform multi-step browser tasks;
- [ ] memory is persistent and user-controllable;
- [ ] all agent capabilities are represented as explicit permissions;
- [ ] Full Access can be granted/revoked by the user;
- [ ] task/session/persistent permission scopes work;
- [ ] agent can use the existing containers, UA, and proxy correctly;
- [ ] agent cannot exceed current grants;
- [ ] model provider can be replaced without redesigning the agent;
- [ ] runtime isolation is demonstrated;
- [ ] end-to-end workflows pass on the actual WebLibre browser;
- [ ] final release artifacts are independently downloadable per supported ABI.

## Current priority order

Do not begin AI implementation until the current browser foundation reaches a stable milestone:

```text
UA restore
 -> UA A/B isolation
 -> proxy regression
 -> targeted validation
 -> stable debug APK (ABI-split artifacts)
 -> Browser Tool API
 -> Agent Core
 -> permissions + memory
 -> first autonomous workflows
 -> model adapters/optimization
 -> end-to-end validation
 -> release APKs per ABI
```

This ordering is deliberate: the agent must operate a stable browser rather than becoming a second source of browser-state bugs.
