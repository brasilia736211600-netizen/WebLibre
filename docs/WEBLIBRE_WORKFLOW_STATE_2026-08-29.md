# WebLibre — Durable Workflow State

**Last synchronized:** 2026-08-29
**Branch:** `weblibre-ua-mainline-v3`
**Last verified branch HEAD before this documentation update:** `edca33b5cb2885261a002092b1a72d6d95dfff27`

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

`packages/flutter_mozilla_components/pigeons/gecko.dart` currently contains:

```dart
class AddTabParams {
  final String url;
  final bool startLoading;
  final String? parentId;
  final LoadUrlFlagsValue flags;
  final String? contextId;
  final String? userAgent;
  final SourceValue source;
  final bool private;
  final HistoryMetadataKey? historyMetadata;
  final Map<String, String>? additionalHeaders;
}
```

Therefore do **not** redo UA-01 or add the same field again.

### Native per-session UA — COMPLETE for the verified creation paths

`GeckoEngineSession` exposes a session-level `userAgentString` backed by GeckoView's `userAgentOverride`.

The verified native creation order is conceptually:

```text
create EngineSession
  -> set session UA
  -> create/use tab state with the prepared session
  -> AddTabAction
  -> first LoadUrlAction
```

This avoids putting UA on the global GeckoRuntime and avoids starting the first navigation with the wrong UA.

### Tab creation variants — COMPLETE at code level

The current verified Dart/native path covers:

- normal `addTab`;
- `addMultipleTabs` with the target container UA treated as authoritative;
- `duplicateTab` passing the container UA to the native layer.

Do not reimplement these paths unless a targeted test or code review finds an actual regression.

### Per-container UA settings UI — COMPLETE at code level

The existing container edit screen was extended with a User-Agent field and persistence using the existing `ContainerMetadata` path.

Do not create another settings screen or another metadata store.

### Native/Kotlin CI — VERIFIED GREEN

The temporary UA verification run successfully passed the expensive native prerequisites and Android Kotlin compilation, including:

- Android toolchain/NDK setup;
- pinned native runtime build;
- Android Kotlin compilation.

The temporary UA verification workflow was then removed because its purpose was completed.

---

## 3. Git/CI cleanup already completed

The branch `weblibre-ua-mainline-v3` is the dedicated UA feature branch.

Obsolete temporary workflow files were removed rather than retained as permanent CI noise. In particular the old Pigeon-generation and P0 temporary workflows referenced stale branches and are no longer part of the working CI path.

The last recorded branch HEAD before this documentation synchronization was:

`edca33b5cb2885261a002092b1a72d6d95dfff27`

with commit message:

`chore(ci): remove obsolete Pigeon generation workflow`

A previous documentation-only checkpoint was:

`3191afab2210f910092b74ed7f2ded6cbe3148f7`

The workflow-state file itself must be updated whenever the branch moves; the SHA written above is therefore a **historical checkpoint**, not a promise that the branch will remain at that SHA.

---

## 4. Exact CURRENT engineering checkpoint

### We are NOT at UA-01 anymore.

The current work has moved to **restore/recovery**.

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
  -> Engine/session restoration path
```

The important verified fact is that the current `RecoverableTab`/`TabState` recovery model carries `engineSessionState` and container `contextId`, but does **not** carry the per-container `userAgent`.

`TabListReducer` only converts the recoverable state into tab session state. It is **not** the correct place to configure Gecko's UA.

### Therefore the exact next implementation/inspection point is:

**Find the concrete EngineSession creation/reuse path used when a restored `TabSessionState` is materialized.**

Determine whether the existing local WebLibre layer lets us apply the container UA at that point without changing the recovery model.

Only if the code proves that the UA cannot reach that point otherwise should we extend `RecoverableTab`/Pigeon or introduce another field.

This is the next blocker.

---

## 5. Restore decision tree — do not over-engineer

Use this decision order:

### Case A — restore already reaches a local session-creation function that knows `contextId`

Prefer the smallest local change that derives the container UA from existing state and applies it before first restored navigation.

No Pigeon change if not needed.
No new recovery model if not needed.

### Case B — restore has no access to the container UA at session creation

Prove that with source inspection first.

Only then consider adding the minimum required UA field to the recovery contract.

If Pigeon must change:

```text
source Pigeon
 -> official generation
 -> generated Dart/Kotlin outputs
 -> targeted compile/test
```

Do not hand-edit generated outputs as independent sources of truth.

### Case C — restore can recover an already-prepared EngineSession

Prefer reusing that capability rather than creating a second UA abstraction.

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

If later required, the safe direction is explicit request/generation/sequence provenance followed by official Pigeon regeneration.

---

## 8. Files already touched for the UA vertical slice

Known feature-related areas include:

- `ContainerMetadata` model/serialization/tests;
- `packages/flutter_mozilla_components/pigeons/gecko.dart`;
- generated Pigeon outputs corresponding to the source contract;
- `GeckoTabsApiImpl` and related native session creation code;
- `TabRepository` / tab creation propagation paths;
- existing container edit/settings UI;
- targeted CI workflow(s), which were later cleaned up after verification;
- this workflow state document.

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

A previous full APK build spent significant time in Gradle/Rust and ended in APK artifact discovery rather than proving the feature itself was invalid. Do not repeat a full build merely to diagnose a narrow failure.

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
- redesign `syncEvents` while working on UA restore;
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

**NEXT:** inspect the concrete restored-tab EngineSession materialization path in local `flutter_mozilla_components` and determine the smallest place where the already-known container UA can be applied before the first restored navigation.

Do not:

- redo `AddTabParams.userAgent`;
- redo normal/multi/duplicate propagation;
- redo the native creation implementation already verified;
- build another UI;
- modify `syncEvents` provenance.

If the restore path proves it cannot access the UA, make the minimum recovery-contract change required and no more.

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
- [ ] restored-tab path preserves and applies the container UA before first restored navigation;
- [ ] runtime A/B isolation regression test;
- [ ] targeted validation of all affected layers;
- [ ] final stable-milestone APK validation.

Proxy hardening and the separate event-correlation track remain distinct workstreams.

---

## 16. Historical correction log

### Correction 2026-08-29

Earlier versions of this document stated that UA-01 through UA-04 and the UI were pending. Subsequent verified source/CI inspection showed those portions had already been implemented on the feature branch.

Those earlier claims are retained only as historical context. They are **not** current TODOs.

The project must always prefer the latest verified source/CI evidence and the newest checkpoint in this file.
