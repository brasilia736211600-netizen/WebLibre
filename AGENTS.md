# WebLibre Agent Operating Manual

## PURPOSE
This repository is an active engineering project. Any AI coding agent entering the repository must use the existing implementation and history, understand the current state, and continue from it. Do not rebuild WebLibre from scratch.

## MANDATORY FIRST ACTIONS
1. Read this file completely.
2. Read `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md` completely.
3. Read `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md` if the agent is Genspark or is being used as a continuation agent.
4. Inspect the actual current branch/HEAD and compare it with the branch's base/mainline.
5. Inspect the current Git diff before making any change.
6. Locate existing tests and CI relevant to the change.

## REPOSITORY SAFETY
The reference repository is:
`https://github.com/brasilia736211600-netizen/WebLibre`

If an agent is operating an experimental fork, ALL writes must remain in that fork. The reference repository must not receive experimental changes.

Never use `main` as a scratch branch.
Never force-push or rewrite unrelated history.
Before changing an existing file, inspect its current contents and current blob SHA.
Never replace a large generated file from a partial snippet.
If an operation produces unrelated deletions, stop and repair them before continuing.

## USER'S ENGINEERING PRIORITIES
The user wants the project advanced as quickly as practical without wasting bandwidth or CI credits. Prefer parallelizable/independent tasks when possible, but do not create races over the same file or branch reference.

Use this working loop:

`inspect -> implement -> targeted test -> inspect diff -> commit -> continue`

Do not spend long cycles only describing future work.

## PRODUCT GOALS
The agreed container-related privacy features are:

1. Independent Proxy per container.
2. Independent User-Agent per container.
3. Per-container settings for both.
4. Durable persistence/restoration.
5. Strict isolation between containers.

The implementation must preserve the existing WebLibre architecture wherever possible.

## USER-AGENT: CURRENT STATE
### Already implemented
`ContainerMetadata.userAgent` exists in the container metadata model.

The data layer covers:
- JSON serialization/deserialization.
- `copyWith`.
- equality/hash participation.
- normalization of empty/whitespace-only values to `null`.
- targeted persistence tests.

Generated Dart serialization is synchronized in the feature work.

### NOT COMPLETE
Do not report User-Agent as complete yet.

Still required:
- pass UA through the real tab/session creation path;
- apply UA to the native Gecko/Engine session;
- apply it before first navigation;
- support single-tab creation;
- support multiple-tab creation;
- support duplicate-tab creation;
- support restore/recovery;
- test two containers concurrently using different UAs;
- add per-container settings UI;
- support clear/reset-to-default;
- verify only the selected container changes.

## UA RUNTIME ARCHITECTURE
The target is session/container scoped UA, NOT a global GeckoRuntime override.

Desired lifecycle:

`ContainerMetadata.userAgent`
` -> tab/session creation`
` -> create EngineSession`
` -> apply session userAgentString / override`
` -> create tab state with prepared session`
` -> AddTabAction`
` -> LoadUrlAction`

The UA must be installed before the first navigation.

A delayed post-navigation setter is not an acceptable primary design because the first request could already have gone out with the default UA.

## NATIVE HOOK ALREADY IDENTIFIED
The local package:

`packages/flutter_mozilla_components/`

contains the project's Kotlin integration with Android Components.

The relevant version investigated is Android Components `152.0.4`.

The critical local file is:

`packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/api/GeckoTabsApiImpl.kt`

Its current important sequence is approximately:

`create tab/session -> AddTabAction -> LoadUrlAction`

Android Components permits a prepared `engineSession` to be supplied when creating the tab. The preferred implementation is therefore to create/prep the EngineSession, set its UA, then create the tab and only after that dispatch the first load.

Do not fork Android Components unless absolutely necessary.

## PIGEON / API RULE
The source contract is in:

`packages/flutter_mozilla_components/pigeons/gecko.dart`

`AddTabParams` is currently the natural contract for carrying tab-creation-specific state.

If UA is added there:
- modify SOURCE Pigeon only;
- run the project's official Pigeon generation task;
- keep generated Dart/Kotlin synchronized;
- do not hand-edit generated output unless generation is truly impossible and the reason is documented.

## CRITICAL RESTORE / EVENT FORENSICS
A separate forensic investigation analyzed container/session restore and tab-list synchronization.

Current API facts:
- `syncEvents()` returns `Future<void>`.
- No request/generation token is returned.
- Tab-list events carry a sequence number but no request provenance.
- stale debounced tab-list events can already be queued.
- RPC and GeckoStateEvents use separate channels.

Therefore a requester cannot mathematically prove that the next tab-list event was caused by its own `syncEvents()` call.

The `_freshSnapshotPending` approach was explicitly rejected as UNSOUND.

If reliable correlation is later required, use explicit request/generation/sequence provenance, then regenerate Pigeon and add concurrency tests.

## PROXY: CURRENT REQUIREMENT
Proxy must be independent per container, not global.

Verify:
- Container A can use Proxy A.
- Container B can use Proxy B.
- changing A never changes B.
- new sessions get the right proxy.
- restored sessions get the right proxy.
- no global GeckoRuntime proxy state is introduced accidentally.
- routing remains fail-closed where the existing proxy snapshot design requires it.

## BUILD / CI EFFICIENCY
A previous Flutter debug workflow spent about 756 seconds reaching Gradle/Rust before failing because the expected APK artifact could not be found:

`Gradle build failed to produce an .apk file. It's likely that this file was generated under /home/runner/work/WebLibre/WebLibre/apps/weblibre/build, but the tool couldn't find it.`

Therefore use the cheapest useful validation first:

1. Dart targeted tests.
2. `flutter analyze`.
3. targeted Kotlin/native checks.
4. Pigeon generation consistency.
5. targeted integration/build.
6. full APK build only at a stable milestone.

Do not repeatedly consume CI/network budget on full APK builds for small changes.

## BRANCH / HANDOFF
The active UA feature work was organized under:

`weblibre-ua-mainline-v2`

A Draft PR was opened as `#2` for the initial data-contract slice.

The durable continuation documents were added to that feature branch:

- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`

These documents are part of the project handoff and should remain synchronized with reality.

## ROADMAP
### Phase A — foundation
- [x] container metadata supports custom UA;
- [x] UA persistence;
- [x] UA data tests;
- [x] established per-container proxy direction.

### Phase B — UA runtime
- [ ] propagate container UA to tab creation;
- [ ] apply UA to EngineSession before first navigation;
- [ ] new tab;
- [ ] multiple tabs;
- [ ] duplicate tab;
- [ ] restore/recovery;
- [ ] runtime A/B isolation test.

### Phase C — container settings
- [ ] UA field in container settings;
- [ ] per-container proxy controls/verification;
- [ ] clear/reset defaults;
- [ ] validation and normalization;
- [ ] selected-container-only mutations.

### Phase D — proxy hardening
- [ ] pre-navigation verification;
- [ ] restore verification;
- [ ] concurrent proxy isolation;
- [ ] regression tests.

### Phase E — restore/event correctness
- [ ] decide if explicit sync request provenance is needed;
- [ ] add generation/request boundary if required;
- [ ] regenerate Pigeon;
- [ ] add concurrency regression tests.

### Phase F — release
- [ ] analyze clean;
- [ ] Dart tests clean;
- [ ] native/Kotlin checks clean;
- [ ] Pigeon generation reproducible;
- [ ] CI green;
- [ ] correct APK artifact detection/upload;
- [ ] stable debug APK;
- [ ] release build.

## NON-NEGOTIABLE INVARIANTS
1. UA is per container/session, never global.
2. Proxy is per container, never silently global.
3. Container A cannot mutate Container B.
4. UA is applied before first navigation.
5. Restore preserves UA/proxy policy.
6. Event arrival order is not proof of request/response correlation.
7. Prefer local WebLibre integration over upstream dependency forks.
8. Generated code stays synchronized with its source.
9. Targeted validation precedes expensive builds.
10. A feature is not complete until both persistence and runtime behavior are verified.

## CONCRETE REPORTING FORMAT FOR AGENTS
When reporting progress, give evidence rather than vague status:

- Current branch:
- Current HEAD/commit:
- Files changed:
- What was actually implemented:
- Tests/checks executed:
- Exact result:
- Known blocker:
- Next concrete action:

Never claim success based only on a design or a model field. Runtime behavior must be demonstrated.

## IMMEDIATE NEXT MISSION
1. Read the handoff documents.
2. Inspect actual current HEAD and diff.
3. Complete the UA runtime vertical slice through EngineSession.
4. Verify addTab/addMultipleTabs/duplicateTab.
5. Implement restore correctly.
6. Add runtime A/B isolation tests.
7. Add container settings UI.
8. Harden proxy isolation.
9. Resolve restore/event provenance if needed.
10. Run full APK validation only after the targeted suite is green.
