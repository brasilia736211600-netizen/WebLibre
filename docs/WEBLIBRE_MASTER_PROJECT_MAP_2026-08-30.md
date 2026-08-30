# WebLibre — Master Project Map

**Created:** 2026-08-30  
**Purpose:** Durable high-level map for resuming WebLibre with a new chat or agent.  
**Repository source of truth:** GitHub code, branch refs, commits, PRs, and CI.  
**Canonical execution state:** `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`  
**Canonical AI specification:** `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

---

## 1. CURRENT POSITION

```text
EXISTING WEB BROWSER FOUNDATION
        |
        v
CONTAINERS + PROXY + PRIVACY + PROFILES
        |
        v
PER-CONTAINER USER-AGENT
        |
        +--> persistence/serialization        [DONE]
        +--> normal/multi/duplicate creation [DONE]
        +--> pre-navigation native UA        [DONE]
        +--> container UA UI                 [DONE]
        +--> restore-source integration      [DONE IN SOURCE]
        |
        v
REAL ANDROID RUNTIME PROOF                 [CURRENT BLOCKER]
        |
        +--> cold-start/restored UA         [NOT VERIFIED]
        +--> Container A/B UA isolation      [NOT VERIFIED]
        +--> Proxy A/B + fail-closed         [NOT VERIFIED]
        |
        v
RELEASE FOUNDATION
        |
        +--> final targeted validation       [PENDING]
        +--> split-ABI APK validation        [PENDING]
        |
        v
AI-1 BROWSER TOOL API                      [NEXT MAJOR PHASE]
        |
        v
AI-2 AGENT CORE
        |
        v
AI-3 PERSONAL PROFILE + MEMORY
        |
        v
AI-4 PERMISSION ENGINE
        |
        v
AI-5 FIRST AUTONOMOUS WORKFLOWS
        |
        v
AI-6 ADVANCED PERSONAL BEHAVIOR
        |
        v
AI-7 MODEL/PROVIDER ADAPTERS
        |
        v
AI-8 END-TO-END VALIDATION
```

### Exact current Git state at map creation

- Active branch: `weblibre-ua-mainline-v3`
- HEAD before this map commit: `533dc9a714eaa6d2dfb615f35787f896e76ddd40`
- PR #3: open, draft, not merged
- PR base: `main`
- Latest verified Quality run before this map commit: #29 / `33327113039` — **SUCCESS**
- The map commit itself is documentation-only and must not be mistaken for a product-code change.

---

## 2. BROWSER FOUNDATION — WHAT IS ALREADY THERE

WebLibre is an existing Flutter/Android GeckoView browser. Do not rebuild it from scratch.

Existing project capabilities include, among other things:

- regular/private/isolated tabs;
- tab organization and parent/child relationships;
- containers and contextual identities;
- profile separation and profile-scoped persistence;
- proxy/Tor routing;
- privacy protections and tracking controls;
- Firefox-compatible extensions;
- local-first search;
- reader/PDF/export/content tools;
- sync and profile backup infrastructure.

These are baseline browser capabilities. The current continuation work is focused on making container identity reliable enough to support the future AI agent.

---

## 3. PER-CONTAINER UA MILESTONE

### Implemented

- `ContainerMetadata.userAgent` exists.
- Blank UA values normalize to `null`.
- Persistence/serialization/equality/copy semantics are implemented.
- `AddTabParams.userAgent` exists in the Pigeon contract and generated bindings.
- Normal tab creation propagates the selected container UA.
- Multiple-tab creation propagates the UA.
- Duplicate-tab creation propagates the UA.
- Native code applies the UA to a prepared `EngineSession` before first navigation for creation paths.
- Existing container edit UI exposes the UA setting.
- `ContainerUserAgentStore.kt` resolves persisted UA from the existing profile-scoped `tab.db` by `contextualIdentity`.
- `HistoryDelegateBindingMiddleware.kt` restores the persisted UA when the native engine session is linked and also handles already-attached sessions on `AddTabAction`.
- No global GeckoRuntime UA was introduced.
- No second database was introduced.
- No `RecoverableTab.userAgent` field was introduced.
- No Android Components fork was introduced.

### Test evidence

- Dart focused container metadata suite: **11/11 GREEN**.
- `ContainerUserAgentStoreTest`: **GREEN** in Quality #29.
- `ContainerProxyFeatureTest`: **GREEN** in Quality #29.
- gomobile runtime build: **GREEN** in Quality #29.
- Gradle/native targeted gate: **GREEN** in Quality #29.

---

## 4. RESTORE — IMPORTANT DISTINCTION

The restore design intentionally uses the existing data sources:

```text
SessionStorage
  -> RecoverableTab / TabSessionState
  -> contextId survives restore
  -> EngineSession creation/link
  -> ContainerUserAgentStore(contextId)
  -> existing tab.db container metadata
  -> userAgent
```

Source implementation is present, but real Android process-death/cold-start behavior is **not yet proven on a device**.

Do not claim runtime restore success from unit tests alone.

### Rejected approach

`_freshSnapshotPending` and similar "first event after syncEvents" freshness heuristics are rejected. The current `syncEvents()` protocol has no request/generation provenance sufficient to prove that an arriving tab-list event was caused by a particular request.

Do not revive that approach without a genuinely changed protocol and a focused proof.

---

## 5. PROXY MILESTONE

### Existing implementation

The project already contains substantial container-aware proxy infrastructure, native extension routing, persistence/replay, generation handling, and fail-closed logic.

Native proxy tests are green.

### Still unverified at runtime

- simultaneous Container A/B proxy isolation;
- restored proxy state after process death/cold start;
- fail-closed behavior on the actual Android runtime;
- regression check that UA and proxy changes in A cannot mutate B.

Do not rewrite proxy architecture merely because runtime proof is pending.

---

## 6. CI HISTORY / CURRENT VALIDATION STATE

Previous causal blocker:

```text
Quality #24 / #25
    -> missing native gomobile AAR
    -> native tests never started
```

Minimal CI-only repair was made by reproducing the already-supported native-runtime prerequisites from the release path:

- Java 17;
- Go 1.25.x;
- pinned Android NDK;
- pinned `sing-box` and `IPtProxy` revisions;
- existing gomobile runtime build before native tests.

Quality #29 subsequently proved the corrected gate green. Therefore the AAR/CI prerequisite blocker is **closed**.

Pinned native revisions remain in `native/go_mobile_runtime/pins.env`.

---

## 7. RELEASE FOUNDATION

Final release policy:

```text
build-browser
   -> --split-per-abi
   -> supported ABI APKs
   -> each APK published/downloadable independently
```

Do not replace this with a universal APK as the default release artifact.

Current release validation is pending the runtime browser milestone.

---

## 8. PERSONAL AI BROWSER AGENT — OFFICIAL ROADMAP

AI is a required final-product track, not optional polish.

### AI-0 — Specification [DONE]

The product requirements and architecture are documented, including:

- owner-only personal agent identity;
- natural-language tasks;
- direct in-WebLibre control;
- authenticated remote control from another phone;
- replaceable transport layer (Telegram/WhatsApp/etc. are transports, not the agent);
- model/provider independence;
- explicit browser-tool boundary;
- controlled memory;
- selectable/revocable permission modes;
- auditability;
- ABI-specific release artifacts.

### AI-1 — Browser Tool API [NOT STARTED]

Required first work:

1. inventory current WebLibre APIs that can support tools;
2. define the smallest internal tool registry;
3. define stable input/output schemas;
4. map each tool to permission scopes;
5. add tool-level audit events.

Representative tools include navigation, observation, interaction, tab management, downloads, containers, proxy, and UA controls. The model must never receive unrestricted internal APIs directly.

### AI-2 — Agent Core [PENDING]

- task intake;
- context construction;
- plan/reason/act/observe loop;
- retries/timeouts/stop criteria;
- provider-neutral model adapter.

### AI-3 — Personal Profile + Memory [PENDING]

- owner profile;
- preferences/instructions;
- short-term task memory;
- long-term user-controlled memory;
- retention/deletion/data minimization.

### AI-4 — Permission Engine [PENDING]

Modes:

`Read Only | Browser Control | Task Control | Trusted Automation | Full Access`

Support one-task, session, persistent, container-scoped and useful site/domain-scoped grants; immediate revocation; visible status; audit history. Remote authentication must never automatically imply Full Access.

### AI-5 — First Workflows [PENDING]

- research/extraction;
- multi-page tasks;
- form filling;
- multi-tab workflows;
- container-aware workflows;
- approved file workflows;
- remote/in-browser task continuity.

### AI-6 — Advanced Personal Behavior [PENDING]

Reusable workflows, user-specific conventions, permitted persistent context, and recovery from common failures.

### AI-7 — Model/Provider Adapters [PENDING]

Provider-neutral interface; remote and local adapters; model selection by task complexity/cost/privacy; context/token budgeting.

### AI-8 — End-to-End Validation [PENDING]

Permission enforcement, revocation, memory isolation/control, browser-state consistency, A/B container isolation, unauthorized-action rejection, remote authentication, remote/in-browser continuity, autonomous task completion, and per-ABI installability.

---

## 9. AI ARCHITECTURE

```text
Direct WebLibre Agent UI ────────────┐
                                    │
Remote phone / replaceable channel ─┼─> Authenticated Gateway
                                    │            |
                                    └────────────v
                                         Personal Agent Core
                                                  |
                       ┌──────────────────────────┼─────────────────────┐
                       |                          |                     |
                 Tool Registry              Permission Engine      Memory Store
                       |                          |                     |
                       └──────────────────────────┼─────────────────────┘
                                                  |
                                           WebLibre Browser
                                                  |
                                    Gecko / tabs / containers /
                                     proxy / UA / page state
```

The browser remains authoritative for actual browser state. The model is a reasoning component, not the authority.

---

## 10. MASTER DEPENDENCY ORDER

This order is intentional:

```text
UA restore proof
    -> UA A/B runtime isolation
    -> Proxy A/B + fail-closed runtime proof
    -> final targeted validation
    -> stable debug/release foundation
    -> AI-1 Browser Tool API
    -> AI-2 Agent Core
    -> AI-3 Profile + Memory
    -> AI-4 Permission Engine
    -> AI-5 workflows
    -> AI-6 advanced behavior
    -> AI-7 model adapters
    -> AI-8 end-to-end validation
    -> final split-ABI APK release
```

Do not jump directly from green unit tests to Agent Core. The purpose of the current browser milestone is to establish a stable, privacy-aware browser authority first.

---

## 11. YAGNI / DO-NOT-REDO LIST

Do not redo or expand these unless a focused test proves a regression or insufficiency:

- container metadata creation;
- UA persistence/serialization;
- existing UA UI;
- normal/multi/duplicate UA propagation;
- native pre-navigation UA application;
- current `ContainerUserAgentStore` architecture;
- current restore architecture;
- proxy architecture;
- CI gomobile prerequisite fix;
- `_freshSnapshotPending` or any event-arrival freshness heuristic;
- `RecoverableTab.userAgent`;
- a second persistence DB;
- global GeckoRuntime UA;
- an Android Components fork;
- unrelated refactors.

---

## 12. PARALLEL EXECUTION RULE

When any independent CI/build/test/run is waiting or in progress, do not remain idle.

Use the waiting interval for independent, non-conflicting work such as:

- inspect source paths and call chains;
- inspect PR diffs/reviews/issues;
- inspect release/build scripts;
- validate documentation/state consistency;
- analyze another independent subsystem;
- prepare the next minimal change without applying it to the same files under active modification.

Parallel work rules:

1. Run only tasks that are logically independent of the active run.
2. Never perform two writes against the same file or dependent code path concurrently.
3. Never duplicate a test/build already running unless there is a concrete diagnostic reason.
4. Prefer read/analysis/review work while CI is executing.
5. As soon as the active run produces a result, reconcile all parallel findings before making a code change.
6. A parallel task must never bypass the dependency order or YAGNI boundary.
7. If parallel work exposes a concrete blocker, fix only the first causal blocker and stop unrelated work.
8. Save every material result back into the durable state files before the next handoff.

Operational loop:

```text
ACTIVE RUN
   ||
   || waiting
   \/
PARALLEL INDEPENDENT ANALYSIS
   ||
   ||
   \/
RECONCILE WITH RUN RESULT
   -> TEST
   -> DIFF
   -> COMMIT
   -> SAVE STATE + UPDATE MAP
```

---

## 13. RESUME RULE FOR ANY NEW AGENT

When a new chat/agent starts:

1. Read this file.
2. Read `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`.
3. Read `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`.
4. Inspect the actual current branch HEAD on GitHub.
5. Inspect the current PR and latest CI run.
6. Compare saved state with actual code before making any change.
7. Continue from the first unchecked item only.
8. Never treat source presence as runtime proof.
9. Never repeat completed work without evidence of regression.
10. While any run/build/CI is waiting, use the Parallel Execution Rule above for independent work.
11. Follow:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

### Map maintenance rule

This map must be updated whenever a material project milestone changes:

- feature implementation;
- runtime validation result;
- test/CI result;
- branch/HEAD/PR state;
- release milestone;
- AI phase advancement;
- blocker resolution.

The short execution truth remains in `WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`; this file is the higher-level project map.

---

## 14. CURRENT CHECKPOINT

**Checkpoint date:** 2026-08-30  
**Branch:** `weblibre-ua-mainline-v3`  
**HEAD before this rule commit:** `ef9a08005b1c9ea4c15814b5c9f8aef85a90378c`  
**Product-code status:** stable at last verified green gate  
**Latest verified CI:** Quality #29 `33327113039` — GREEN  
**Current live CI:** Quality #32 `33328637149` — in progress at gomobile runtime build when this checkpoint was recorded  
**Current blocker:** real Android runtime proof for UA restore, UA A/B isolation, and Proxy runtime behavior  
**Next execution:** while CI runs, perform independent source/release analysis; after CI result, reconcile and then proceed to cold-start/restored-tab UA validation -> Container A/B isolation -> Proxy A/B/fail-closed -> final validation -> split-ABI release validation -> AI-1.
