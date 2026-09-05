# Genspark + WebLibre — Exact Setup, Low-Credit, Fork-Safe

## Goal
Use Genspark as the coding agent for WebLibre without uploading the whole repository into Hub and without allowing experiments to touch the reference repository.

Reference repository:
`https://github.com/brasilia736211600-netizen/WebLibre`

Create a separate experimental fork first. All Genspark writes must happen in that fork.

## 1. Create the NEW GitHub fork

1. Open the reference repository on GitHub.
2. Click **Fork**.
3. Choose the GitHub account that should own the experimental copy.
4. Use a distinct name such as:
   `WebLibre-genspark-lab`
5. Create the fork.
6. Open the new fork and copy its URL.
7. Keep the original WebLibre repository as reference/read-only.

If Genspark later says it cannot fork, this is normal for some connector/tool configurations. Create the fork manually as above, then give Genspark the NEW fork URL.

## 2. Connect GitHub inside Genspark

Genspark currently documents GitHub as a Developer/Collaboration connector.

Path:
**Skills -> Connectors -> GitHub -> Install/Connect -> GitHub OAuth -> Connected**

A successful OAuth connection does not guarantee that the selected agent exposes fork/create/push operations. Test its capabilities before asking it to write.

## 3. Create the Hub

Genspark Help Center currently documents:
**Hub in left sidebar -> + New -> name/theme/description -> Create Hub**.

### Hub name
`WebLibre — Container Isolation Engineering`

### Hub description
`Continue and complete the existing WebLibre Android browser project from its current engineering state. Preserve the existing architecture while completing independent per-container User-Agent and Proxy configuration, persistence, restoration, runtime isolation, per-container settings UI, targeted tests, CI hardening, and final APK validation. The reference repository must remain protected; all implementation must happen in a separate fork. Prefer targeted validation before expensive full builds.`

## 4. Add Hub Custom Instructions

Paste this into the Hub's Custom Instructions:

```text
You are the senior engineering agent for an existing WebLibre Android browser project.

REPOSITORY SAFETY
- Reference repository: https://github.com/brasilia736211600-netizen/WebLibre
- Treat the reference repository as READ-ONLY.
- All code, experiments, branches, commits, CI changes and tests MUST happen in a separate fork/copy.
- Never push experimental changes to the reference repository.
- Inspect repository URL, branch, HEAD and diff before editing.
- Keep commits atomic and reviewable.
- Never overwrite large generated files from partial snippets.
- If unrelated deletions appear, stop and repair them.

PROJECT GOAL
Complete independent per-container User-Agent and Proxy configuration, persistence/restoration, runtime isolation, per-container settings UI, tests, CI/build hardening and final APK validation.

UA RULE
UA is per container/session. NEVER implement it as a global GeckoRuntime setting. Apply it to the EngineSession/GeckoSession BEFORE first navigation.

PROXY RULE
Proxy is per container. Never silently convert it into global runtime state.

KNOWN FORENSIC RULE
The existing syncEvents() tab-list API lacks request/generation provenance. _freshSnapshotPending was rejected as unsound. Do not use event arrival order as proof of request/response correlation.

LOW-CREDIT MODE
- Do not upload the whole source tree to Hub when GitHub repository access is available.
- Do not repeatedly run full APK builds.
- Prefer source inspection, focused searches, targeted tests, small diffs and atomic commits.
- Validate before expensive builds.

VALIDATION ORDER
1. targeted Dart tests
2. flutter analyze
3. targeted Kotlin/native tests/checks
4. Pigeon generation consistency
5. targeted integration/build
6. full APK only at a stable milestone

HANDOFF
Before coding, read:
- docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md
- docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md
- docs/GENSPARK_HUB_AND_GITHUB_STEP_BY_STEP_2026-08-28.md

WORK LOOP
inspect -> implement -> test -> inspect diff -> commit -> continue

Never claim a feature is complete without code and test evidence.
```

## 5. Do NOT upload the full repository

Genspark Hub supports Hub files, but its current Help Center specifically recommends keeping files minimal because too many files increase credit consumption.

For this project, the only useful Hub documents are:

1. `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
2. `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`
3. this guide

Do NOT upload:
- the complete WebLibre source tree;
- repository ZIP files;
- `.git`;
- build output;
- Gradle caches;
- Rust output;
- APKs/binaries.

If Genspark Code can directly connect/import the GitHub repository, prefer that. The repository stays the source of truth.

## 6. If Genspark asks for Hub file uploads

Only download the three small documentation files from the NEW fork's `docs/` directory.

On GitHub:
1. Open the NEW fork.
2. Open `docs/`.
3. Open each handoff file.
4. Use the available download/raw action.
5. Save the files to the phone.
6. In Genspark Hub open **Files** and add only those three Markdown files.

There is no reason to download the full repository ZIP just to provide context.

## 7. Start the coding project

Inside the Hub:
1. Create a new project/task.
2. Choose **Genspark Code** when available.
3. Connect/select the NEW fork, never the reference repository.
4. If a repository URL field is shown, paste the NEW fork URL.
5. Do not upload the repository ZIP.

## 8. EXACT text for "What are you trying to achieve?"

Paste exactly this:

```text
Continue and complete the existing WebLibre Android browser project from its current engineering state in a NEW fork only. Preserve its architecture while completing independent per-container User-Agent and Proxy configuration, persistence, restoration, runtime isolation, per-container settings UI, targeted regression tests, CI hardening, and final APK validation. The reference repository must remain untouched. First inspect the actual repository, current branch, HEAD, and diff; read the WebLibre handoff documents; then implement incrementally using inspect -> implement -> test -> inspect diff -> commit -> continue. Apply User-Agent at GeckoSession/EngineSession scope before first navigation, never globally at GeckoRuntime. Keep Proxy independently scoped per container. Respect the known restore/event correlation limitation and do not use the rejected _freshSnapshotPending approach. Prefer targeted tests and small diffs before expensive full APK builds. Never claim a feature is complete without code and test evidence.
```

## 9. First prompt to Genspark after repository connection

Do NOT ask it to implement everything immediately. First verify state:

```text
You are taking over WebLibre in this NEW fork only.

First verify:
1. exact repository URL;
2. current branch;
3. current HEAD SHA;
4. comparison against the fork's main branch;
5. current UA state;
6. current Proxy state;
7. current restore/event forensic state.

Then read:
- docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md
- docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md
- docs/GENSPARK_HUB_AND_GITHUB_STEP_BY_STEP_2026-08-28.md

DO NOT MODIFY CODE YET.
Return only a compact state report and the single highest-priority implementation target.
Do not run a full APK build.
```

## 10. Second prompt: authorize actual work

```text
Proceed in the NEW fork only.

Use:
inspect -> implement -> test -> inspect diff -> commit -> continue

Start with the highest-value unchecked item: complete per-container User-Agent runtime integration.

Requirements:
- preserve existing architecture;
- do not use a global GeckoRuntime UA;
- apply UA to the EngineSession before first navigation;
- preserve container identity;
- cover new tab, multiple tabs and duplicate tab;
- handle restore explicitly;
- add regression tests;
- use official Pigeon generation when needed;
- run targeted validation before any expensive APK build.

When one task is complete, continue to the next safe unchecked task without waiting for me.
If an action would affect the reference repository, STOP that action and continue with safe work in the NEW fork.
Every meaningful update must include actual evidence: branch, commit SHA, files changed, tests/results, and next task.
```

## 11. If Genspark says "my GitHub tools cannot fork"

Do not fight the connector.

1. Fork manually on GitHub.
2. Copy the NEW fork URL.
3. Connect GitHub in Genspark.
4. Select the new repository if the UI offers it.
5. Otherwise paste the URL.
6. Send:

```text
The fork was created manually.
Work ONLY in this repository:
<NEW FORK URL>

The reference repository is read-only.
Verify the repository identity, branch and HEAD SHA first.
Read docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md.
Then continue the implementation from the first unchecked item.
```

## 12. How to minimize Genspark credits

Do not use one giant prompt such as "analyze and finish the whole repository".

Use focused turns:

Turn 1: state verification.
Turn 2: UA runtime tracing and implementation.
Turn 3: targeted tests/fixes.
Turn 4: multiple/duplicate tab coverage.
Turn 5: restore behavior.
Turn 6: container settings UI.
Turn 7: proxy isolation/restore hardening.
Turn 8: CI artifact/build fix.
Turn 9: final tests.
Turn 10: full APK build.

Avoid repeating broad analysis after each small code change.

## 13. Parallel work

Use parallel agents only for independent read-heavy tasks or separate files.

Good:
- UA runtime audit;
- proxy isolation audit;
- CI APK artifact investigation;
- settings UI audit.

Bad:
- two agents editing `gecko.dart`;
- two agents editing `GeckoTabsApiImpl.kt`;
- two agents changing the same workflow;
- simultaneous rebases of the same branch.

One agent should own each shared file.

## 14. Git evidence check

After meaningful work, ask:

```text
Print the exact repository URL, branch, HEAD SHA, last 5 commits, and current diff against the fork's main branch. Confirm that the reference repository was not modified.
```

If the URL is the reference repository, STOP immediately.

## 15. Definition of done — UA

UA is complete only when:
- configurable per container;
- persisted;
- restored;
- applied before first navigation;
- correct for multiple tabs;
- correct for duplicated tabs;
- correct for restored tabs;
- two containers can use different UAs concurrently;
- reset returns that container to default;
- UI changes only the selected container;
- regression tests pass.

Proxy is complete only after equivalent runtime isolation and restore verification.

## 16. Resume prompt after interruption

```text
Resume from the existing WebLibre engineering state in the NEW fork.
Read docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md first, inspect actual HEAD and diff, do not repeat completed work, and continue with the highest-priority unchecked item.
Work only in the NEW fork.
```

## 17. Important project facts

- Local Native package: `packages/flutter_mozilla_components/`
- Android Components version investigated: `152.0.4`
- Native UA integration point identified: `GeckoTabsApiImpl`
- Correct order: prepare EngineSession -> apply UA -> create tab state -> AddTabAction -> LoadUrlAction.
- Previous full debug build spent about 756 seconds and failed at APK artifact discovery, so full builds are last, not first.
- `_freshSnapshotPending` is rejected and must not be resurrected as a reliable sync correlation mechanism.

## 18. Handoff documents in repository

The current feature branch contains:
- `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
- `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`
- `docs/GENSPARK_HUB_AND_GITHUB_STEP_BY_STEP_2026-08-28.md`

These documents are intended to let a new AI agent continue without reconstructing the previous investigation.
