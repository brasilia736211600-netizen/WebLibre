# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Current verified branch HEAD:** `8fc79ddac6fc2bc939c9449861de137db174a47f`

## Purpose — READ THIS FIRST

This is the project's **durable execution memory**.

A new AI agent must read this file before doing implementation work. It must not reconstruct the project from chat history when the repository already contains the facts.

The canonical supporting documents are:

- `AGENTS.md`
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`
- `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK.md`
- this file: `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`

**Source-of-truth rule:** actual current Git state, current source code, current CI evidence, and the newest update to this file override stale claims in older handoff documents.

**Persistence rule:** after every meaningful implementation/checkpoint, update this file with the new branch/HEAD, files changed, tests/checks, result, and exact next step. Do not leave the durable state describing an obsolete stage.

---

## 1. Current project objective

Complete and harden per-container privacy identity in the existing WebLibre fork:

1. independent proxy per container;
2. independent User-Agent per container;
3. persistence/restoration;
4. strict A/B isolation;
5. minimal changes to the existing architecture;
6. final validation and APK only after cheaper targeted checks pass.

Do **not** rebuild WebLibre from scratch.
Do **not** move container UA or proxy state to a global GeckoRuntime setting.

---

## 2. Current verified status — important correction to older documents

Some older handoff text still describes UA native/UI work as pending. That text is historical and is now stale.

The work completed after that handoff was verified during the current continuation:

### UA data foundation — COMPLETE

- `ContainerMetadata` contains `String? userAgent`.
- persistence/serialization/`copyWith`/equality/normalization are implemented;
- model tests were added and passed in the earlier implementation cycle.

### UA Pigeon contract — COMPLETE

`packages/flutter_mozilla_components/pigeons/gecko.dart` currently carries `userAgent` through the existing tab-creation contract (`AddTabParams`). Do not add the same field again.

### Native per-session UA — COMPLETE for the verified creation paths

`GeckoEngineSession.settings.userAgentString` maps to GeckoView's session-level `userAgentOverride`.

The verified native creation order is:

```text
create EngineSession
  -> set session UA
  -> create/use tab state with the prepared session
  -> AddTabAction
  -> first LoadUrlAction
```

This avoids a global GeckoRuntime UA and avoids starting the first navigation with the wrong UA.

### Tab creation variants — COMPLETE at code level

The current verified Dart/native path covers:

- normal `addTab`;
- `addMultipleTabs` with the target container UA authoritative;
- `duplicateTab` passing the container UA to native.

Do not reimplement these paths unless a targeted test or code review finds an actual regression.

### Per-container UA settings UI — COMPLETE at code level

The existing container edit screen has a User-Agent field persisted through `ContainerMetadata`.

Do not create another settings screen or another metadata store.

### Native/Kotlin CI — VERIFIED GREEN (historical)

The temporary UA verification run successfully passed the native runtime prerequisites and Android Kotlin compilation (recorded in PR #3 as workflow run `33265003957`). The temporary verification workflow was removed afterward.

This is historical evidence only; the current PR head has no active CI status yet.

---

## 3. Current Git / PR / CI reconciliation

The originally referenced P0 branch is no longer the execution branch for this feature:

- `weblibre-p0-container-restore` is at `87b450ed584a3f81bb37a4cc4261e7a553d164fa`.
- The active UA work is on `weblibre-ua-mainline-v3` at `8fc79ddac6fc2bc939c9449861de137db174a47f`.
- PR #3 is the active feature PR, draft, base `main`, head `weblibre-ua-mainline-v3`.
- Current combined status for `8fc79dd...`: no status checks reported.
- Current PR-triggered workflow runs for `8fc79dd...`: none reported.
- The branch has diverged substantially from the old P0 branch; do not silently switch back to it.

The requested workflow-state file was absent on the default branch and the old P0 branch, but is present on the active UA branch. Therefore the active branch/file pair is the authoritative continuation point.

---

## 4. Exact CURRENT engineering checkpoint

### Restore/recovery is the current blocker.

The verified restore chain is:

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

### Materialization finding — VERIFIED 2026-08-29

The concrete native materialization path was inspected in Android Components:

- `CreateEngineSessionMiddleware` creates the session from `TabSessionState.private/contextId` and restores the engine session state before linking.
- `GeckoEngineSession.restoreState()` calls `GeckoSession.restoreState(...)`.
- `GeckoSession.restoreState()` restores saved browser session data; current GeckoView documentation describes restored data as history, scroll position, zoom, and form data, not session settings/user-agent override. citeturn112577search7
- `GeckoEngineSession.settings.userAgentString` is a separate `GeckoSession.settings.userAgentOverride` value.

The repository's Android Components session-storage serializer was also inspected:

- `BrowserStateWriter` serializes `TabSessionState` fields and `engineSession` separately, but there is no UA field in the persisted tab state.
- `BrowserStateReader` reconstructs `RecoverableTab.state` from those same fields; there is no UA field.
- therefore UA is **not** persisted/restored by the existing Android Components session-storage contract.

### Important consequence

A Pigeon-only `RecoverableTab.userAgent` addition would fix only the Dart-driven `restoreTabsByList` path. It would **not** fix the native cold-start restore from `SessionStorage`, which occurs inside `GlobalComponents.setUp()` before Flutter can supply Dart container metadata.

Therefore do **not** add a recovery field yet. The next implementation must address the cold-start/native restore path as well, with the smallest local mechanism that can provide the container UA before `CreateEngineSessionMiddleware` calls `restoreState()`.

---

## 5. Current design decision tree — updated

### Preferred Case A — native restore can obtain persisted container UA before session creation

Use the existing WebLibre native startup/persistence pattern to make a minimal native lookup available to the restore materialization path, then apply the UA to the just-created session before `restoreState()` / first restored load.

Avoid global GeckoRuntime settings.
Avoid changing Android Components upstream if the local integration can do it.

### Case B — native restore cannot access persisted container UA without extending the recovery/storage contract

Only after proving Case A impossible, extend the smallest local persistence/recovery contract necessary. Keep Dart and native generated Pigeon outputs synchronized through the official generation path if Pigeon changes.

### Case C — a prepared EngineSession can be injected into the restore path

Prefer reusing that capability rather than introducing a second UA abstraction.

---

## 6. Isolation requirement

The feature is not complete until runtime isolation is demonstrated:

```text
Container A -> UA-A
Container B -> UA-B

change A -> B remains UA-B
```

The same isolation principle applies to proxy state:

```text
Container A -> Proxy-A
Container B -> Proxy-B

change A -> B remains Proxy-B
```

A global GeckoRuntime setting is forbidden because it cannot satisfy the required container isolation invariant.

---

## 7. Separate forensic track — DO NOT MIX INTO UA UNLESS REQUIRED

The `syncEvents()` / tab-list freshness problem is separate from the current UA restore task.

Known facts:

- `syncEvents()` returns `Future<void>`;
- tab-list events carry a sequence number;
- current events do not contain request/generation provenance;
- stale debounced events may already be queued;
- RPC and `GeckoStateEvents` use separate channels;
- awaiting the RPC does not prove that the next tab-list event belongs to that request.

Therefore `_freshSnapshotPending`-style arrival-order heuristics are unsound.

Do not reopen this work merely because restore is being investigated. Only touch it if the actual restore implementation proves it requires a reliable sync correlation mechanism.

---

## 8. Files already touched for the UA vertical slice

Known feature-related areas include:

- `apps/weblibre/lib/features/geckoview/features/tabs/data/models/container_data.dart`
- `apps/weblibre/lib/features/geckoview/domain/repositories/tab.dart`
- `apps/weblibre/lib/features/geckoview/domain/providers/tab_state.dart`
- `apps/weblibre/lib/features/geckoview/features/tabs/data/database/daos/container.dart`
- `packages/flutter_mozilla_components/pigeons/gecko.dart`
- generated Pigeon outputs corresponding to the current source contract;
- `packages/flutter_mozilla_components/lib/src/domain/services/gecko_tab.dart`
- `packages/flutter_mozilla_components/android/.../api/GeckoTabsApiImpl.kt`
- `packages/flutter_mozilla_components/android/.../components/Core.kt`
- `packages/flutter_mozilla_components/android/.../middleware/HistoryDelegateBindingMiddleware.kt`
- existing container settings UI;
- targeted CI workflow(s), later cleaned up after verification;
- this workflow-state document.

Do not assume every historical file remains changed on current HEAD. Always inspect the actual current tree/diff before editing.

---

## 9. Testing/build discipline

Use the cheapest validating check that can prove the current change.

Preferred sequence:

```text
focused source inspection
 -> targeted Dart/unit test or analyze
 -> targeted Kotlin/native compile/test
 -> Pigeon generation check only if source contract changed
 -> targeted integration/build
 -> full APK only at a stable milestone
```

The user has limited mobile data, so prefer CI/in-repo evidence over repeated device/APK downloads.

---

## 10. YAGNI rules for every future agent

Before editing, answer internally from source:

1. What exact behavior is missing?
2. Which existing function already owns that lifecycle?
3. Can the current state already carry the required value?
4. Can the existing API be reused?
5. What is the smallest file/diff that fixes the demonstrated gap?

Do **not**:

- redo completed UA contract/propagation/native work;
- add global settings;
- refactor unrelated tab/container architecture;
- create duplicate UI/settings paths;
- create temporary CI workflows unless strictly necessary;
- modify Android Components upstream when local integration can solve it;
- add Pigeon fields before proving the field is required;
- redesign `syncEvents` provenance;
- run a full APK build before cheaper checks pass.

---

## 11. Mandatory agent execution loop

Every coding task must follow:

```text
READ THIS FILE
  -> READ canonical handoff/playbook when needed
  -> VERIFY current branch/HEAD
  -> INSPECT exact source path
  -> IDENTIFY the demonstrated gap
  -> MAKE the smallest safe change
  -> TEST the changed behavior
  -> INSPECT diff against base
  -> ENSURE no unrelated changes
  -> COMMIT atomically
  -> UPDATE THIS FILE
```

The agent must not stop after saying what it intends to do. For an implementation task it should execute the next safe step unless blocked by a concrete dependency.

If CI is running, work in parallel only on independent files/tasks. Never let parallel work overwrite the same source or generated Pigeon output.

---

## 12. Mandatory checkpoint record after EVERY meaningful step

After every meaningful implementation, test, CI result, cleanup, or architectural discovery, update this file.

Append or revise these fields:

```text
Timestamp/date
Branch
HEAD SHA
Task completed
Files changed
Tests/checks
Result
Current blocker
Exact next action
```

Never leave the file claiming that a completed stage is pending.

When correcting stale historical statements, explicitly mark them as stale rather than silently carrying them forward.

---

## 13. Quick resume command for a new AI agent

A user can open a new chat and send only:

```text
@GitHub @Thinking
استأنف WebLibre من ملف docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md.
اقرأه أولًا، ثم تحقق من branch/HEAD/CI/diff الفعلي.
لا تعِد أي عمل مكتمل.
استخدم YAGNI وأصغر تغيير ممكن.
تابع من Exact Current Engineering Checkpoint.
بعد كل خطوة مهمة حدّث نفس الملف بالـ HEAD والملفات والاختبارات والنتيجة والخطوة التالية.
نفّذ العمل، ولا تكتفِ بتقرير.
```

The agent must treat that as an instruction to read the repository's durable memory rather than asking the user to re-explain the project.

---

## 14. Current exact next action

**NEXT:** identify the smallest existing native persistence/snapshot mechanism that can expose `container contextId -> userAgent` during `GlobalComponents.setUp()` before `restoreBrowserState()` creates restored engine sessions.

Inspect existing native startup snapshots and their Dart writers first. Do not add a new Pigeon contract until those routes are exhausted.

Once a concrete native pre-restore mapping exists:

1. apply UA to restored sessions before `restoreState()`;
2. add focused regression coverage for restore;
3. prove A/B runtime isolation;
4. run targeted validation;
5. only then build the milestone APK.

---

## 15. Definition of done for the current UA feature

UA is complete only when all are true:

- [x] container UA model/persistence;
- [x] source Pigeon tab contract;
- [x] normal new-tab path;
- [x] multiple-tab path;
- [x] duplicate-tab path;
- [x] native session-level override before first navigation for those creation paths;
- [x] existing container settings UI path;
- [ ] cold-start/restored-tab path preserves and applies the container UA before first restored navigation;
- [ ] runtime A/B isolation regression test;
- [ ] targeted validation of all affected layers;
- [ ] final stable-milestone APK validation.

Proxy hardening and the separate event-correlation track remain distinct workstreams.

---

## 16. Historical correction log

### Correction 2026-08-29 — Git state and restore path

The older state file incorrectly left the branch HEAD at `edca33b5...` and treated the materialization path as still unknown. Current Git truth is `weblibre-ua-mainline-v3` at `8fc79dd...`.

Current source inspection now proves the restored-session materialization path and proves that Android Components `SessionStorage` does not serialize container UA in `TabSessionState`.

This is a correction of the execution state, not a request to redo any completed UA creation work.
