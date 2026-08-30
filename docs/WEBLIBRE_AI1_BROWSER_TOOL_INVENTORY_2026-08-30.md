# WebLibre AI-1 — Browser Tool Inventory Baseline

**Date:** 2026-08-30
**Status:** inventory/design preparation only; no Agent runtime implementation.
**Purpose:** prepare AI-1 while Android runtime validation is performed later, without coupling the Agent to internal APIs or adding speculative abstractions.

## Operating rule

Android device validation is **not** a reason to stop independent project preparation. Work that can be completed and validated from repository/CI evidence may proceed in parallel. Do not duplicate active CI/builds, and do not claim Android runtime behavior is proven until it is actually exercised.

## Current browser surfaces observed in source

The existing `TabRepository` is already a high-level orchestration boundary for tab operations and delegates engine work to `GeckoTabService`. It currently exposes/implements these candidate capabilities:

| Candidate tool | Existing source capability | AI-1 status |
|---|---|---|
| `create_tab` | `TabRepository.addTab` | candidate |
| `create_tabs` | `TabRepository.addMultipleTabs` | candidate |
| `duplicate_tab` | `TabRepository.duplicateTab` | candidate |
| `close_tab(s)` | repository close paths | candidate |
| `switch_tab` | selected-tab/provider paths | candidate |
| `get_tabs` | tab-list/provider/database state | candidate |
| `get_current_tab` | selected-tab/provider state | candidate |
| `select_container` | selected-container provider/repository | candidate |
| `get_container` | container repository | candidate |
| `get_container_settings` | container metadata/repository | candidate |
| `set_container_user_agent` | existing container metadata/settings path | candidate |
| `set_container_proxy` | existing proxy routing repository/settings path | candidate |

The source also contains browser services/providers and replication services that may support future tool implementations. These should be adapted behind a tool boundary rather than exposed directly to a model.

## Tool families from the product specification

The authoritative initial tool list remains:

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

This document does **not** claim all of these already have a suitable WebLibre implementation. Each must be mapped to an existing stable browser capability before implementation.

## Minimal AI-1 contract

Every implemented tool must have exactly one explicit contract containing:

1. stable tool name;
2. typed input schema;
3. typed output schema;
4. required permission scope;
5. side-effect classification;
6. reversibility classification;
7. optional confirmation category;
8. deterministic error/result envelope;
9. audit event definition.

The model must never receive unrestricted repository/provider objects, Pigeon APIs, database handles, or Gecko internals.

## First implementation slice

When AI-1 implementation begins, use the smallest useful vertical slice:

```text
get_tabs
get_current_tab
create_tab
switch_tab
close_tab
open_url
```

Reason: these establish read-state + basic navigation/tab mutation without prematurely implementing downloads, file access, page extraction, external communication, proxy mutation, or memory.

The next slice can add page interaction only after the first tool contract is tested.

## Permission mapping baseline

```text
get_tabs             -> read_browser_state
get_current_tab      -> read_browser_state
create_tab           -> tabs + navigate
switch_tab           -> tabs
close_tab            -> tabs
open_url             -> navigate
read_page            -> read_page_content
inspect_page         -> read_page_content
screenshot           -> read_page_content
click/type/scroll    -> interact
select_container     -> containers
set_container_proxy  -> proxy
set_container_user_agent -> user_agent
```

A tool must not silently inherit `Full Access`; permission evaluation remains an independent layer.

## Explicit non-goals for AI-1

Do not implement yet:

- LLM/provider integration;
- Agent planning loop;
- personal memory;
- Telegram/WhatsApp transport;
- autonomous workflows;
- a second browser-control API;
- direct model access to GeckoView/Pigeon internals;
- speculative abstractions for Android runtime behavior.

## Dependency position

```text
Browser Foundation runtime proof ──────┐
                                       │
AI-1 inventory/design ──> tool contracts ──> registry ──> Agent Core
                                       │
                                       └── may progress independently
```

The existing Browser Foundation remains the source of truth for actual browser state. AI-1 must wrap it, not replace it.

## Evidence used for this baseline

- `TabRepository` currently orchestrates tab creation, multiple-tab creation, duplication, container selection, persisted tab metadata, and Gecko tab service calls.
- `WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md` defines the model-independent Browser Tool API and permission requirements.
- `WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md` defines the dependency order and YAGNI boundaries.

## Next AI-1 step

**Implement the minimal typed tool contract/registry only after confirming the exact existing APIs for the six-tool first slice.** No model integration and no new browser-state persistence should be introduced.
