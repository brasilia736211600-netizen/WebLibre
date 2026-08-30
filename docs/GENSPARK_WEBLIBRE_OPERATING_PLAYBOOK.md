# Genspark WebLibre Operating Playbook

Date: 2026-08-28

## Purpose

This document explains exactly how to use Genspark to continue WebLibre with minimum wasted credits, minimum repeated context, and maximum engineering reliability.

## 0. Golden rule

Never give Genspark a giant unstructured prompt for every turn.

Use one durable project document plus short task prompts.

The canonical project handoff is:

`docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`

The dedicated Genspark continuation prompt is:

`docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`

This playbook is the operational procedure.

## 1. Recommended Genspark setup

Use Genspark Hub for the long-running project when available. Hub projects share files/context across conversations, so you do not need to re-upload the same project material repeatedly. Keep the number of files intentionally small because Genspark itself recommends keeping Hub files minimal to reduce credit consumption.

Recommended Hub contents:

1. `WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
2. `GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`
3. `GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK.md`

Do NOT upload the entire repository as dozens/hundreds of individual files merely to establish context. Let the coding agent inspect the fork itself.

## 2. Which Genspark mode to use

For actual code implementation, use Genspark Code / the coding-oriented Super Agent path.

For project management/context, Hub is useful.

For repetitive project-specific behavior, save a Skill only after the workflow is stable.

For broad autonomous multi-step work, the new Super Agent can execute long tasks and can work in parallel. Use parallelism only when tasks are independent and cannot overwrite the same files simultaneously.

## 3. First session — create a NEW fork

The first instruction to Genspark must be explicit:

- do not modify the reference repository;
- create a new fork/copy first;
- perform all experimentation in the new fork;
- preserve git history;
- never push to the original reference repository.

Then make Genspark read:

`docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`

and

`docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`

Do not ask it to immediately change code.

The first task should be an inspection-only task:

> Create the new fork. Read the three project-control documents. Inspect the current HEAD, branch list, diff against mainline, CI, Pigeon sources, and `packages/flutter_mozilla_components`. Do not modify code. Return only the current branch/commit, relevant open PRs, changed files, and the exact next implementation point.

This small inspection is cheaper and safer than allowing a coding agent to improvise from an incomplete mental model.

## 4. After inspection — use narrow execution prompts

Use one prompt per vertical slice.

Good:

> Implement only the UA runtime vertical slice. First inspect the exact current source. Then modify the minimum required files, generate Pigeon output from source, run targeted tests, inspect the diff, and commit. Do not touch unrelated features.

Bad:

> Finish everything in WebLibre and fix all problems.

The second form causes excessive exploration, unrelated changes, and unnecessary credit consumption.

## 5. Engineering loop

Force the agent to use this loop:

`inspect -> implement -> targeted test -> inspect diff -> commit -> next task`

Do not let it repeatedly narrate intentions without changing or testing code.

At the end of each task require:

- current branch;
- HEAD SHA;
- changed files;
- tests executed;
- results;
- next blocker.

## 6. Credit-saving model strategy

Genspark currently recommends shaping the prompt before sending the expensive execution request. Use normal chat to refine the task first, then hand the final prompt to Super Agent/Code.

Use the lowest model tier that is sufficient for the current step.

Use expensive reasoning/model tiers only for:

- architectural decisions;
- concurrency/restore bugs;
- native API integration;
- complicated failures.

Use cheaper tiers for:

- locating files;
- summarizing diffs;
- small tests;
- documentation;
- commit message drafting.

Do not ask the high-end agent to rediscover facts already recorded in the handoff documents.

## 7. Credit-saving context strategy

Do not paste large source files into chat.

Instead tell Genspark exactly which file/path to inspect.

Bad:

> Here are 10,000 lines of Kotlin, find the bug.

Good:

> Read the implementation of `GeckoTabsApiImpl.addTab()` and the source Pigeon definition of `AddTabParams`. Report the current lifecycle and the smallest safe insertion point.

For every new session, reference the handoff document instead of retelling the whole project.

## 8. Parallel work strategy

Use parallel tasks only for independent areas.

### Safe parallel examples

Task A:
- inspect and test the UA data/model layer.

Task B:
- inspect CI and reduce unnecessary full APK builds.

Task C:
- inspect restore/event correlation and propose a mathematically reliable API.

### Unsafe parallel examples

Do NOT run two agents simultaneously editing:

- `gecko.dart`;
- `GeckoTabsApiImpl.kt`;
- generated Pigeon outputs;
- the same workflow file.

Pigeon source and generated code must be treated as one dependency chain.

## 9. UA implementation sequence

Use these separate Genspark tasks:

### UA-01: contract

Add `userAgent` to the SOURCE Pigeon/tab creation contract only.

Then generate Pigeon output.

Run targeted compile/analyze checks.

### UA-02: propagation

Find the Dart caller that knows the assigned container and propagate its `ContainerMetadata.userAgent` into the tab-creation request.

Do not redesign container state.

### UA-03: native session

Modify `GeckoTabsApiImpl` so the EngineSession is prepared with the per-container UA BEFORE the first `LoadUrlAction`.

Required conceptual order:

`create EngineSession -> set UA -> create tab with prepared session -> AddTabAction -> LoadUrlAction`

### UA-04: coverage

Cover:

- addTab;
- addMultipleTabs;
- duplicateTab.

### UA-05: restore

Handle restored tabs separately and ensure restored navigation cannot occur with the wrong/default UA first.

### UA-06: isolation

Add a runtime test proving:

`Container A = UA-A`
`Container B = UA-B`

and that changing A cannot affect B.

### UA-07: UI

Only after runtime behavior passes, add/finish the per-container settings UI and reset-to-default behavior.

## 10. Proxy implementation sequence

After UA runtime is stable, use similarly narrow tasks:

1. inspect current per-container proxy lifecycle;
2. verify new-tab pre-navigation application;
3. verify simultaneous different proxies;
4. verify restore;
5. test Container A != Container B;
6. fix only the failed path;
7. add UI only after runtime behavior is correct.

Never move proxy state to a global GeckoRuntime setting just because it is easier.

## 11. Restore/event investigation task

When you revisit the restore synchronization issue, give the agent the exact invariant:

> A received tab-list event must be provably attributable to the requested synchronization operation. Arrival order is not sufficient.

Require it to reason about:

- stale queued debounce events;
- separate RPC/event channels;
- request/generation provenance;
- sequence boundaries.

Reject any `_freshSnapshotPending`-style heuristic that cannot establish provenance.

## 12. Handling failures cheaply

When a task fails:

1. Do NOT immediately rerun the full APK build.
2. Extract the exact failure.
3. Ask the agent to classify it as Dart, Pigeon, Kotlin/native, Gradle, Rust, or artifact discovery.
4. Run the smallest diagnostic that can distinguish those classes.
5. Patch only the failing layer.
6. Run targeted tests.
7. Run full APK only after targeted tests pass.

For the historic APK issue, remember that the long Gradle/Rust build ended with an artifact-discovery failure, so rebuilding the same way without checking the output path is wasteful.

## 13. Git discipline in the new fork

Every Genspark session must operate only inside the NEW fork.

Before editing an existing file:

- inspect current HEAD;
- inspect file contents;
- inspect diff against base.

After editing:

- inspect diff;
- ensure no unrelated files changed;
- commit atomically.

Do not squash or rewrite history merely to hide mistakes.

## 14. Pigeon discipline

Source of truth:

`packages/flutter_mozilla_components/pigeons/gecko.dart`

Generated outputs should be produced by the project's Pigeon generation task.

Do not hand-maintain generated Dart/Kotlin files as independent sources of truth.

If generated output changes unexpectedly, stop and inspect why before committing.

## 15. Low-credit progress prompts

Use very short progress requests between work packages.

Examples:

> Continue UA-02 only. Inspect first. Implement, test, commit. Do not touch UI.

> Continue from the last commit. Run only targeted tests for the files changed. Do not run the full APK.

> Inspect current diff and fix only compile errors introduced by the previous commit.

> Check whether UA-A and UA-B remain isolated. Add the smallest regression test.

Avoid repeatedly sending:

> continue

because it can force the agent to infer the next scope from the whole project and spend more tokens deciding what to do.

## 16. When to use a new Genspark conversation

Stay in the same project/Hub when context is still relevant.

Start a new conversation when:

- the conversation has become dominated by old failed experiments;
- the agent repeatedly re-reads irrelevant material;
- a milestone is complete and the next phase has a different technical context.

When starting a new conversation, point it to the same handoff files. Hub can provide cross-project/shared context, but keep the task prompt narrow.

## 17. Save a reusable Skill later

Once the inspect/test/commit workflow has proven stable, create a Genspark Skill for the WebLibre engineering protocol.

The Skill should encode:

- fork-only rule;
- read handoff first;
- targeted tests before APK;
- atomic commits;
- no main branch experiments;
- evidence-based progress reporting;
- YAGNI/minimal-diff behavior;
- per-container isolation invariants.

Do not build the Skill before the workflow is stable; otherwise every iteration becomes another source of duplicated instructions.

## 18. Suggested master prompt for the first implementation session

Use this after the inspection-only step:

> You are the senior implementation agent for the NEW WebLibre fork only.
>
> Read `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`, `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`, and `docs/GENSPARK_WEBLIBRE_OPERATING_PLAYBOOK.md`.
>
> Do not modify the original reference repository under any circumstance.
>
> Continue from the actual current HEAD; do not assume earlier chat claims are code-complete.
>
> Immediate objective: complete the per-container User-Agent runtime vertical slice.
>
> Required order:
> `inspect -> implement -> generate -> targeted test -> inspect diff -> commit`
>
> Scope:
> 1. Add UA to the source tab-creation/Pigeon contract.
> 2. Regenerate Pigeon output using the official project command.
> 3. Propagate the assigned container's UA from Dart.
> 4. In local `GeckoTabsApiImpl`, create/prep the EngineSession with the container UA before first navigation.
> 5. Cover new tab, multiple tabs, and duplicate tab.
> 6. Add the smallest meaningful isolation tests.
> 7. Do not implement UI until runtime behavior passes.
>
> Constraints:
> - UA must be per-container/session, never global GeckoRuntime state.
> - Container A must never change Container B.
> - Do not modify Android Components upstream.
> - Do not hand-edit generated Pigeon outputs unless generation itself is broken and the reason is documented.
> - Do not run the full APK build until targeted checks pass.
>
> At the end, report only concrete evidence: branch, HEAD SHA, files changed, tests, results, and remaining blocker.

## 19. Suggested short prompts after the master task

### Continue

> Continue from the last successful commit. Work on the next unchecked item in the handoff document. Inspect first, make the smallest safe change, run targeted tests, commit, and report evidence.

### Failure repair

> Diagnose only the current failing check. Do not redesign unrelated code. Identify root cause, patch the smallest layer, run the smallest validating test, inspect diff, and commit.

### Release gate

> Run the release-readiness checklist from the handoff document. Do not build APK until all cheaper checks pass. Report blockers with exact logs and paths.

## 20. What you should manually watch

You do NOT need to supervise every agent action.

Only inspect manually when the agent reports:

- a permission/authentication request;
- a destructive repo operation;
- an unexplained mass diff;
- a request to modify the original reference repository;
- a native architectural change broader than the current feature scope;
- a release/signing/key operation.

For ordinary code edits and tests, let the agent proceed.

## 21. Final handoff rule

Before switching back from Genspark to another agent, require it to update:

`docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`

with:

- completed items;
- current branch/commit;
- files changed;
- tests and results;
- exact next blocker;
- any architectural decisions.

This document is the project's durable state, not the chat transcript.

## 22. Credit-minimization summary

The most efficient workflow is:

`Hub + 3 small control docs -> inspection-only task -> narrow vertical slice -> targeted tests -> atomic commit -> next slice -> final APK`

Avoid:

`upload whole repository -> giant prompt -> full APK after every change -> repeated re-explanation -> multiple agents editing same files`

The first workflow minimizes repeated context, avoids needless large builds, and makes parallel work safer.
