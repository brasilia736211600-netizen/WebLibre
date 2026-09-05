# Genspark Setup & Execution Guide — WebLibre

Date: 2026-08-28

This guide is for using Genspark to continue WebLibre WITHOUT manually uploading the whole repository. The preferred method is to connect GitHub as a Connector and let the coding agent read/write the repository through GitHub.

## A. Important separation

There are two repositories/concepts:

1. Reference/current repository:
   `https://github.com/brasilia736211600-netizen/WebLibre`

2. Genspark working fork:
   A NEW repository created for experimentation/implementation.

NEVER let Genspark push experimental changes to the reference repository. The new fork is the disposable/working copy.

## B. Create the Hub

In Genspark:

1. Open **Hub** from the left sidebar.
2. Select **+ New**.
3. Hub name:
   `WebLibre Engineering — Container Isolation`
4. If there is a theme-color selector, leave the default or choose a neutral engineering color.
5. For **Hub description** use:

   `Long-running engineering workspace for continuing the WebLibre Android browser project. The goal is to preserve the existing architecture while completing and hardening independent per-container User-Agent and Proxy configuration, persistence, restoration, runtime isolation, container settings UI, CI validation, and final Android APK builds. GitHub is the source of truth. Work must happen only in a dedicated fork/feature branches; never modify the reference repository for experiments.`

6. Create the Hub.

Genspark Hub is designed to keep related projects together and share context across projects, so this Hub should be the permanent workspace for the continuation. Do not create a new unrelated Hub for every task.

## C. Set Hub Custom Instructions

Open the Hub's settings/edit area and put the following in Custom Instructions:

`You are a senior software engineer/release engineer continuing an existing WebLibre Android browser project. GitHub is the source of truth. Preserve the existing architecture; do not rebuild from scratch. Before changing anything, inspect the actual repository state, current HEAD, branches, PRs, CI workflows, and diffs. NEVER modify the reference repository for experiments. All experiments and implementation must happen in a NEW fork and dedicated feature branches. Keep commits atomic and reviewable. Never overwrite large generated files from partial snippets. Generate Pigeon output from source using the project's official generator. Prefer targeted Dart/unit/analyze/native checks before expensive APK builds. The current engineering goal is independent per-container User-Agent and Proxy with persistence, restoration, runtime isolation, and per-container settings UI. UA must be session/container scoped, not global GeckoRuntime state, and must be applied before first navigation. The prior forensic conclusion is that syncEvents() cannot reliably correlate tab-list events with a request without explicit provenance; do not use arrival-order heuristics or revive _freshSnapshotPending. Always provide concrete evidence: branch, commit SHA, files changed, tests run, results, and remaining blockers. Do not claim a feature is complete without code/test evidence.`

## D. Connect GitHub — do NOT upload the repository manually

Do NOT download the complete GitHub repository to your phone and upload it to Genspark Hub Files. That would waste bandwidth, duplicate the repo, increase context/credit consumption, and create version drift.

Instead use Genspark's GitHub Connector if available in your account:

1. Open Genspark **Skills** / **Connectors**.
2. Find **GitHub**.
3. Select **Connect / Install**.
4. Complete the GitHub OAuth authorization.
5. Grant repository access to the WebLibre repository/workspace needed for the task.
6. Return to the Hub/project.

Genspark documentation states that GitHub is a supported Developer connector and that connectors can be connected once and reused by skills that need them. Genspark also supports attaching a GitHub repository as context rather than requiring a manual file upload.

## E. If Genspark offers “Add context” / “Attach”

Inside the first project prompt:

1. Click the **+** / attachment button.
2. Choose **GitHub repository** rather than local files.
3. Select the WebLibre repository.
4. Choose the branch/ref you want the agent to inspect.

Do NOT attach a ZIP of WebLibre.

## F. What to do when GitHub “Fork” fails

If GitHub's normal web Fork button fails, do NOT repeatedly retry it and do NOT download/upload the repo.

Use this strategy:

### Preferred
Ask Genspark's GitHub-connected agent to create a NEW repository/copy using the GitHub connector or its available repository-management action, and then work only there.

Tell it explicitly:

`The reference repository is https://github.com/brasilia736211600-netizen/WebLibre. Create a completely separate working fork/copy under the account/workspace you control. Do not modify the reference repository. Preserve history. If the GitHub connector does not support the Fork operation, create a new repository and reproduce the repository's current state/history using the safest supported Git operation, then work only in that new repository.`

### If the agent cannot create repositories
Stop before giving it write access to the reference repo. Use a new empty repository only if the Genspark environment can populate it safely. Do not let it push directly to the reference repo.

## G. First Genspark project: exact name

Project name:

`WebLibre — Engineering Continuation / Container Isolation`

## H. First project prompt — FULL VERSION

Paste this after connecting GitHub:

`You are taking over an active WebLibre engineering project. Before making any code changes, read docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md and inspect the actual repository state. Also read docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md and this guide if available.

CRITICAL SAFETY RULE: the current/reference repository is https://github.com/brasilia736211600-netizen/WebLibre. DO NOT modify, push to, merge into, or otherwise alter that reference repository for experiments. Create a NEW fork/copy first and do ALL work in the new fork only. Preserve the complete history. If the normal GitHub Fork button is unavailable, use the GitHub connector/repository tooling to create a separate repository/copy. Do not download and upload the entire repository just to create context.

After the new fork exists, inspect:
- actual HEAD;
- default branch;
- feature branches;
- open PRs;
- current diff against mainline;
- CI workflows;
- packages/flutter_mozilla_components/;
- exact Android Components dependency version;
- the current ContainerMetadata implementation;
- Pigeon source and generated outputs.

Do not rebuild the application from scratch.

PROJECT GOAL:
Complete the existing WebLibre Android browser while preserving its architecture and implementing/hardening:
1. independent Proxy per container;
2. independent User-Agent per container;
3. per-container settings UI for both;
4. persistence and restoration;
5. strict runtime isolation so Container A can never silently affect Container B;
6. targeted tests, CI correctness, and final APK validation.

CURRENT UA STATUS:
The data foundation already exists: ContainerMetadata.userAgent, persistence, copyWith, equality/normalization, generated serialization, and targeted tests. Do NOT call UA complete.

CORRECT UA RUNTIME DESIGN:
UA is GeckoSession/EngineSession scoped, NOT global GeckoRuntime state.
Required lifecycle:
ContainerMetadata.userAgent
 -> tab/session creation
 -> create EngineSession
 -> apply session userAgentString/override
 -> create tab state with the prepared session
 -> AddTabAction
 -> LoadUrlAction

UA MUST be applied before first navigation.

NATIVE INTEGRATION POINT:
packages/flutter_mozilla_components/ contains the local Kotlin integration. GeckoTabsApiImpl is the critical native point. The existing flow is approximately:
addTab -> create TabSessionState -> AddTabAction -> LoadUrlAction
Android Components supports using a prepared EngineSession when creating the tab. Use that to avoid a first-navigation race.

IMPLEMENTATION ORDER:
1. Inspect exact Pigeon source for AddTabParams and GeckoTabsApi.
2. Add userAgent to SOURCE contract only.
3. Run the official Pigeon generator.
4. Propagate the assigned container's userAgent from Dart.
5. Prepare the EngineSession in GeckoTabsApiImpl and apply UA before first load.
6. Cover addTab.
7. Cover addMultipleTabs.
8. Cover duplicateTab.
9. Handle restore/recovery explicitly so restored navigation cannot happen with the wrong UA.
10. Add a runtime isolation test proving two simultaneous containers can use different UAs.
11. Add/finish per-container settings UI.
12. Harden and test Proxy isolation and restore.

PROXY:
Container A may use Proxy A while Container B uses Proxy B. Changing A must never mutate B. Verify new sessions and restored sessions. Never introduce accidental global proxy state.

RESTORE FORENSICS:
The existing syncEvents() API returns Future<void> and has no request/generation token. Tab-list events carry sequence information but no request provenance; stale debounced events may exist; RPC and event channels are separate. Therefore arrival-order correlation is not mathematically reliable. The prior _freshSnapshotPending approach was rejected as UNSOUND. If reliable request/event correlation is needed, introduce explicit request/generation/sequence provenance and regenerate Pigeon.

BUILD/CI:
A previous debug build spent roughly 756 seconds in Gradle/Rust and then failed because the expected APK artifact could not be found. Therefore validate in this order:
1. Dart/unit tests
2. flutter analyze
3. targeted Kotlin/native checks
4. Pigeon generation consistency
5. targeted build/integration
6. full APK build only after stability.

GIT SAFETY:
- Work ONLY in the new fork.
- Never push experiments to the reference repository.
- Use dedicated feature branches.
- Keep commits atomic.
- Inspect current content/SHA before changing existing files.
- Never overwrite large generated files from partial snippets.
- Generate Pigeon from source.
- Compare feature branch against base after significant changes.
- Stop and repair unrelated deletions.

WORKING STYLE:
Use this loop continuously:
inspect -> implement -> test -> inspect diff -> commit -> continue
Do not spend long cycles merely describing plans.
Provide concrete evidence after each milestone: branch, commit SHA, files changed, tests, results, blockers.
Do not claim a feature is complete unless code and tests demonstrate it.

FIRST ACTION:
Create the NEW fork/copy and prove that the reference repository is untouched. Then read the handoff map and begin the UA runtime vertical slice.`

## I. First response you should require from Genspark

After the first prompt, do not immediately ask it to build an APK. Require a short evidence report first:

`Before implementing, return only a repository-state report containing: new fork repository URL/name; default branch; current HEAD SHA; relevant feature branch/PR; current diff summary; exact Android Components version; exact files where ContainerMetadata, AddTabParams, GeckoTabsApi, GeckoTabsApiImpl, and tab creation are defined; and your proposed first atomic commit. Do not modify code yet.`

This is a cheap inspection task and prevents an expensive wrong implementation.

## J. Then give implementation permission

After the inspection report, send:

`Proceed with the first atomic implementation slice only: add userAgent to the source tab-creation contract, regenerate Pigeon, propagate the container value to the native tab creation path, and apply it to the EngineSession before first navigation. Run targeted tests/analyze. Do not run a full APK build yet. Work only in the new fork.`

## K. Low-credit operating mode

Use the following order to minimize Genspark credits:

1. One Hub, not many Hubs.
2. One main engineering project inside that Hub, plus small focused follow-up projects only when necessary.
3. Use GitHub connector context instead of uploading source files.
4. Do not upload ZIPs, `build/`, `.gradle/`, `.dart_tool/`, generated APKs, NDK artifacts, or Rust build output.
5. Do not ask the agent to summarize the entire repository repeatedly.
6. Keep the handoff documents in the repo so the agent can read them when needed.
7. Ask for targeted inspections before implementations.
8. Run cheap tests before expensive builds.
9. Reuse previous project context inside the Hub instead of repeating the entire prompt.
10. Ask for one logical change at a time when a change is risky; group only tightly coupled source/generated changes.

Genspark's Hub documentation explicitly recommends keeping Hub files minimal because too many files increase credit consumption. The preferred setup here avoids Hub file uploads almost entirely and keeps GitHub as the source of truth.

## L. What NOT to upload to Hub

Do not upload:
- complete WebLibre ZIP;
- `.git/`;
- Android build directories;
- Gradle caches;
- Rust target directories;
- `.dart_tool/`;
- generated APK/AAB files unless a specific analysis task needs them;
- dependency caches.

Only upload a small file when the agent genuinely cannot access it through GitHub.

## M. Progress checkpoints

After every meaningful change ask Genspark to report:

`Report: branch, HEAD SHA, commit SHA, files changed, tests run, exact pass/fail result, and next single action. Keep it factual.`

When a test fails:

`Do not rebuild the APK. Inspect the failure, identify the smallest root cause, patch it, rerun the targeted check, and report the evidence.`

## N. APK rule

Do not let Genspark repeatedly run full APK builds. Full builds are the expensive last-mile validation. First establish:

Dart tests -> analyze -> native targeted tests -> Pigeon generation -> targeted build -> full APK.

## O. Completion gate

Do not mark the project complete until all of these are proven:

UA:
- configurable per container;
- persisted;
- restored;
- applied before first navigation;
- correct for multiple tabs;
- correct for duplicate tabs;
- correct for restored tabs;
- simultaneous different UAs work in different containers;
- reset/default works;
- settings affect only selected container;
- regression tests pass.

Proxy:
- independently configurable per container;
- applied before navigation;
- restored correctly;
- simultaneous different proxies work;
- changing A does not affect B;
- regression tests pass.

Release:
- Dart tests clean;
- analyze clean;
- native checks clean;
- generated Pigeon reproducible;
- CI green;
- APK artifact path fixed;
- full APK built only after all of the above pass.
