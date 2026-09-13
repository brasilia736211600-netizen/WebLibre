# FAS Autonomous WebLibre Next Build

## Purpose

This branch is the isolated execution line for building the next WebLibre product with FAS as the autonomous engineering controller.

GitHub is the source of truth. Do not use chat memory as evidence.

## Baseline

Base source: `FaFre/WebLibre` (AGPL-3.0), with this repository's current WebLibre engineering work as the starting point.

Starting branch: `fas-weblibre-next`

Starting source checkpoint: `32f9e2d98df30dc24cf64414de6f17d077570b8d`.

The branch is intentionally separate from `main` and the existing draft UA PR branches.

## Product goal

Build a lightweight, reliable Android browser that preserves WebLibre's Gecko/Android Components foundation while consolidating the highest-value features already requested across WebLibre and HebLibre.

The implementation must prefer existing GeckoView/Android Components/Web APIs, small deterministic seams, local-first storage and low lifecycle cost. Do not introduce heavy frameworks merely to imitate an agent/browser feature that can be implemented directly.

## Required product feature set

### Browser foundation

- GeckoView/Android Components based browser.
- Fast startup and lifecycle/crash hardening.
- Regular, Private and Isolated browsing modes where supported by the existing architecture.
- Rich tab management: list/grid/tree, stacking/parent-child relationships, pinning, filtering, reorder, bulk actions, quick switching.
- Container/workspace model with fast switching.
- Persistent session restoration.
- Deterministic restoration ordering: persisted identity/settings must be applied before restored navigation consumes them.

### Profiles/workspaces

- Named reusable profiles.
- Profile metadata: name, icon/color, group, tags, notes.
- Search/filter/sort.
- Fast profile switching.
- Explicit duplicate/template semantics.
- Profile-local tabs, history, bookmarks, sessions, downloads metadata and curated settings.
- Profile deletion with deterministic purge of owned records.
- Profile consistency/health diagnostics.
- Profile backup/export/import with versioned format.
- Optional encrypted transfer using well-defined cryptographic primitives already acceptable to the project.
- Transactional import and malformed/tampered/wrong-password rejection.

### Privacy and security

Retain and strengthen the legitimate privacy baseline already present in WebLibre:

- HTTPS-only.
- Global Privacy Control.
- Save-Data where supported.
- Tracking/query-parameter cleanup.
- Third-party cookie controls.
- Screenshot protection where supported.
- Media and geolocation permission guards.
- Safe Browsing where supported.
- Profile-aware/site-aware allowlists.
- Popup/redirect/resource controls with measurable tests.
- Privacy and Storage diagnostics.
- Per-profile clearing.
- Site permission policy/store/editor.

Do not add operational third-party anti-fraud bypass, identity-verification bypass, ban evasion, stealth bot behavior, detection-evasion fingerprint spoofing, or credential/session theft.

### Network and identity controls

- Profile/container scoped proxy configuration using only platform-supported mechanisms.
- Proxy bypass rules.
- Curated UA presets.
- Custom UA.
- Preferred language.
- Apply process-wide proxy configuration at startup when AndroidX WebKit limitations require it; do not claim hot per-WebView proxy switching unless platform support is genuinely available and verified.
- Preserve the per-container UA lifecycle correction and re-read-live-state hardening already present on the source branch.

### Local-first organization and social-web utilities

- Bookmarks and history.
- Download manager metadata and controls.
- Selection/copy/share helpers.
- Page preview where supported.
- Translation.
- Zoom and sound controls.
- PDF/print/full-page export where feasible.
- Page notes.
- RSS/Atom support where already architecturally justified.
- Bang providers/custom search engines.
- Local search across tabs/bookmarks/history/feeds and page text where privacy settings allow.

### Developer and diagnostics tooling

- Page diagnostics and observable browser state inspection.
- Resource/popup/redirect diagnostics.
- API testing tools as observability/testing features.
- Privacy & Fingerprint Exposure Audit as read-only diagnostics.
- Report exposed browser/platform signals without forging them for third-party evasion.
- Deterministic test pages for owned/authorized endpoints.

### Authorized security laboratory

Keep this isolated from the normal browser surface.

Provide a local or explicitly configured test endpoint model that can:
- define controlled scenarios;
- vary legitimate test signals;
- assert expected detector outcomes;
- capture evidence and hashes;
- report false-positive/false-negative results;
- maintain regression cases.

Never expose a portable arbitrary-site evasion switch.

### Personal AI Browser Agent

Implement the agent only behind stable internal WebLibre APIs.

Required architecture:

`WebLibre Agent UI + authenticated remote control -> Personal Agent Core -> Permission Engine + Browser Tool Registry + Memory -> WebLibre browser state/tools`

The agent must be model-provider independent.

Required initial tool boundary:

- get_tabs
- get_current_tab
- create_tab
- switch_tab
- close_tab
- open_url
- search
- read_page
- inspect_page
- screenshot
- click
- click_by_text
- click_by_role
- type_text
- select_option
- scroll
- press_key
- back
- forward
- reload
- wait
- find_in_page
- duplicate_tab
- get_downloads
- start_download
- read_file
- write_file
- select_container
- get_container
- get_container_settings
- set_container_proxy
- set_container_user_agent

Every tool must declare permission scope, input/output schema, side-effect metadata, reversibility and confirmation category where relevant.

Permission modes:
- Read Only
- Browser Control
- Task Control
- Trusted Automation
- Full Access

Permissions must support one-task, session, persistent, container-scoped and site/domain-scoped grants where useful, with immediate revocation and an auditable grant history.

The agent may not silently escalate permissions.

Personal memory must be separate from the model provider and explicitly user-controlled: inspect, edit, export, clear and disable.

Only minimum necessary browser-local data may be sent to a model provider.

The remote transport must be replaceable. Telegram/WhatsApp are transport candidates, not architectural dependencies. Remote authentication is not itself a permission grant.

### Release and validation

- GitHub Actions build/test is mandatory.
- Prefer deterministic unit/widget/integration tests before APK work.
- Use a consolidated emulator smoke pass after source and CI gates are green.
- Keep physical-device testing as the final coherent validation stage.
- Produce independently downloadable ABI-specific APK artifacts for supported ABIs; use split packaging rather than a universal merged APK where supported.
- Verify APK integrity/checksums in CI.

## Engineering rules

1. Follow: `READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> REVIEW -> COMMIT -> SAVE STATE`.
2. TDD where practical: establish a failing focused test before implementing a behavior change.
3. YAGNI: implement the smallest complete seam, not speculative frameworks.
4. Prefer existing project architecture over parallel subsystems.
5. Preserve source/runtime boundaries; never claim capabilities that are not verified.
6. Do not repeatedly build/install APKs while developing individual features.
7. Every material feature must justify startup, RAM, storage, battery, dependency and lifecycle cost.
8. No destructive git operations: no reset --hard, clean, force-push, mass deletion, or unrelated overwrite.
9. Keep changes scoped and reviewable.
10. Generated artifacts and FAS state must not pollute commits.
11. Existing unrelated work must be preserved.
12. Security-sensitive behavior must remain within the legitimate privacy/authorized-lab boundary defined above.

## Execution order

### Phase 0 — reconcile

Read these sources before changing production code:
- `docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- this file
- authoritative HebLibre product scope: `brasilia736211600-netizen/HebLibre/docs/HEBLIBRE_PRODUCT_SCOPE_2026-09-06.md`
- authoritative HebLibre project map: `brasilia736211600-netizen/HebLibre/docs/HEBLIBRE_MASTER_PROJECT_MAP.md`

Then inspect current branch/HEAD, open PRs, recent relevant commits and CI state.

### Phase 1 — release-quality foundation

Close the current WebLibre runtime/validation gates without discarding existing work.

Priority:
1. current-source Quality/CI truth;
2. current-head validation APK retrieval and verification;
3. API-35 emulator smoke;
4. restore/container/UA correctness;
5. privacy/permission baseline;
6. profile/workspace primitives.

Do not start the largest AI features before the browser foundation is stable enough to serve as the source of truth for agent actions.

### Phase 2 — profile/workspace consolidation

Implement or reconcile:
- profiles;
- metadata/groups/tags/notes;
- local history/bookmarks/tabs/session ownership;
- duplication/template semantics;
- transfer/import/export;
- permission editor;
- site-data management;
- profile health diagnostics;
- network/identity settings.

### Phase 3 — privacy and social-web layer

Implement/extend:
- popup/redirect/resource controls;
- download/bookmark/history tooling;
- search/bangs/local index;
- translation/zoom/sound/PDF/notes;
- privacy/storage diagnostics;
- read-only fingerprint exposure audit.

### Phase 4 — Browser Tool boundary

Create the model-independent registry and stable schemas first. Add focused permission and side-effect tests for every tool.

### Phase 5 — Personal Agent Core

Implement:
- task intake;
- context builder;
- planner/reasoner adapter;
- observation loop;
- stop/retry/timeout policy;
- browser-state consistency;
- progress/results UI.

### Phase 6 — permission + memory

Implement the five permission modes, grant scopes, revocation, audit history, personal agent profile and user-controlled memory.

### Phase 7 — first agent workflows

Prove deterministic end-to-end flows:
- research and summarize;
- navigate and collect structured data;
- fill a user-authorized form;
- multi-tab workflows;
- container switching;
- browser-approved download organization;
- continuation between WebLibre UI and authenticated remote control.

### Phase 8 — provider adapters

Only after the browser/tool/permission architecture is stable:
- provider-neutral model interface;
- remote adapter(s);
- optional local adapter(s);
- task-based model routing;
- context/token budgeting.

### Phase 9 — authorized security laboratory

Implement controlled endpoint scenarios, detector assertions, reproducibility metadata, evidence capture and regression suites.

### Phase 10 — final validation

Run the project validation ladder:

`SOURCE-VERIFIED -> TEST-VERIFIED -> CI-VERIFIED -> ANDROID-RUNTIME-VERIFIED -> ARTIFACT-VERIFIED -> RELEASE-READY`

Do not claim the later state from an earlier one.

## FAS execution contract

When this file is used as the task passed to `fas run`, the agent must:

- inspect first and establish a baseline;
- select the smallest next vertical slice;
- make only task-related changes;
- run the narrowest relevant tests, then the broader required suite;
- leave a clean, explainable diff;
- commit only when tests pass and scope is clean;
- use conventional commit messages;
- push only when explicitly enabled by the FAS invocation;
- record important state/evidence in the repository's durable docs rather than chat.

For CI failure recovery, FAS must continue to use its existing bounded evidence->scope->repair->test->scoped-commit->push loop rather than allowing the model to choose an unrestricted repository scope.

## Definition of Done for WebLibre Next

The branch is not complete until the browser foundation, profile/workspace layer, privacy/social tools, Browser Tool API, Personal Agent Core, permissions, memory, model adapters and authorized lab each have source/tests/CI evidence appropriate to their stage; emulator validation is green; supported APK artifacts are independently verifiable; and the final product behavior is documented without overclaiming unsupported isolation or network capabilities.
