# WebLibre AI Coordination & Continuity Checkpoint — 2026-09-02

## Purpose

This file is the durable cross-chat / cross-agent continuity checkpoint for the WebLibre project. It prevents the next Codex session or agent from depending on conversational memory. GitHub repository state, commit SHAs, PR refs, CI runs, and committed project-state documents are authoritative.

## Authoritative repository state at checkpoint creation

- Repository: `brasilia736211600-netizen/WebLibre`
- Working branch: `weblibre-ua-mainline-v3`
- HEAD at checkpoint: `54434b795844d5b915fc72fa9f4e793577cf6202`
- HEAD short: `54434b7`
- Parent: `eea4b40baef357136d38e057f708106aeb112da0`
- Open PR: `#3`
- PR title: `feat(containers): complete per-container User-Agent vertical slice`
- PR base: `main`
- PR current head: `54434b795844d5b915fc72fa9f4e793577cf6202`
- `main` and `weblibre-ua-mainline-v3` are substantially divergent; do not merge/rebase blindly.

## Required resume procedure

At the start of every new WebLibre chat, Codex task, or agent session:

1. Read this file.
2. Read the current project map and workflow state when present:
   - `docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
   - `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
   - `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`
3. Read the active product/architecture evidence relevant to the next task, especially:
   - `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
   - `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`
   - `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md`
   - `docs/WEBLIBRE_RUNTIME_UA_RESTORE_FORENSICS_2026-08-31.md`
   - `docs/WEBLIBRE_PRIVACY_DATA_FLOW_AUDIT_2026-08-31.md`
   - `docs/WEBLIBRE_PERSONAL_PRODUCT_IDENTITY_2026-08-31.md`
4. Verify actual GitHub branch/HEAD, recent commits, PR head, and latest relevant CI/build/release evidence before changing code.
5. Reconcile saved state against actual GitHub refs. Never trust a stale checkpoint over the repository.
6. Select exactly one next bounded engineering step before execution.
7. Execute → focused test → inspect diff → commit → update state.
8. Never claim Android-runtime verification without actual Android-device evidence.

## Current product/work state

### Container / User-Agent vertical

- The per-container UA source implementation is present on `weblibre-ua-mainline-v3`.
- The source slice and focused CI work previously reached source/CI verification for the proven paths.
- Android physical runtime validation is still blocked at **Scenario 1**.
- Scenario 1 observed: before process death the configured UA was Chrome/120; after relaunch/restoration the restored navigation used Gecko/Firefox 152. There was no usable “Resume last tab” control in the tested flow.
- Until Scenario 1 passes, do not spend runtime-test effort on Scenarios 2–6.
- Do not introduce a global Gecko UA, heuristic freshness workaround, second persistence database, new recovery Pigeon field, `RecoverableTab.userAgent`, or an Android Components fork merely to bypass this blocker.

### AI-1 browser tools

- AI-1 tool contracts/registry/executor work exists in the current line.
- The tool set includes:
  - `get_tabs`
  - `get_current_tab`
  - `create_tab`
  - `switch_tab`
  - `close_tab`
  - `open_url`
- A historical Quality run failed on an older merge commit, not on the current `54434b7` source. Failure was a missing non-null return in `browser_tool_executor.dart` during `execute()` compilation.
- Current source must be checked against the exact current HEAD before making any executor fix. The current file appeared to contain an explicit failure fallback after the tool switch, so do not blindly reapply the old patch.

### Agent Core

- AI-2 / broader Agent Core work has **not started** and should remain downstream of AI-1 and the browser runtime contract being sufficiently proven.

### Privacy

- Privacy hardening has substantial source work but outstanding cleanup/audit items remain. Do not declare privacy complete without current source/CI evidence.
- Re-check background-feed fetching, dead account-sync paths, and outbound endpoint/data-flow coverage before release claims.

## Verified CI/build evidence retained from prior checkpoints

- Flutter CI run: `33420348298`
- Job: `99580917046`
- Verified commit at that time: `eea4b40baef357136d38e057f708106aeb112da0`
- Result: SUCCESS.
- Stable APK build/validation release was previously successful at that checkpoint.
- Historical Quality run: `33335697412`, job `99322082446`, based on an older merge path involving `c557c914c3493c1eeafbe15de6fb757f1016ab8f` and merge commit `896283...`.
- Historical failure root cause: `browser_tool_executor.dart` lacked a return for `BrowserToolExecutionResult`; asset-path warnings were not the root cause.
- Current docs-only `54434b7` does not by itself prove a new product CI result. Re-run/inspect exact-head CI when source changes or a CI-triggering commit is created.

## Engineering invariants / non-negotiables

- YAGNI: do the smallest change that closes the current verified gap.
- Evidence precedence: current repository/CI/runtime evidence > stale documents > conversation memory.
- Maintain the evidence chain:
  `SOURCE-VERIFIED → CI-VERIFIED → ANDROID-RUNTIME-VERIFIED → ARTIFACT-VERIFIED → RELEASE-ASSET-VERIFIED`.
- Never equate `await syncEvents()` with proof that a fresh snapshot was consumed.
- Never use `_freshSnapshotPending` as a freshness proof; stale debounced events and separate RPC/event timing make arrival order insufficient.
- Do not modify generated Pigeon/Drift artifacts manually unless the repository's generation workflow explicitly requires it.
- Do not erase unrelated user work or broad-clean the checkout.
- Do not claim tests/builds/runtime behavior from reasoning or old logs; use fresh evidence.

## AI engineering stack and role boundaries

- **Codex Coordinator:** goal-scoped ownership, visible work boundaries, collision avoidance, and integration of 2–3 substantial independent verticals only when they are truly independent.
- **Engineering Guardrails:** smallest reliable implementation slices, root-cause analysis, focused-to-broad verification, and adaptive parallelism.
- **Process Jobs:** long-running builds/tests/benchmarks so the primary work session is not consumed by waiting.
- **get-fable:** lifecycle routing and durable handoff/discovery/planning/execution/verification flow.
- **AI DevKit:** specialized agent management, communication, TDD, debugging, verification, review, and lifecycle support.
- **CodeRabbit:** independent review after a meaningful code slice/PR; it is not a substitute for local verification.
- **Advisor:** one-shot read-only consultation for material architecture/interface/concurrency/security decisions only.
- **Yaps / durable memory:** reusable project knowledge and architectural decisions; never store transcripts or volatile command logs as memory.
- **Prompt Optimizer:** use only for long/complex user requests when converting them into an execution brief materially helps.
- **Plugin Autopilot:** unrelated to normal WebLibre browser implementation; use for Plugin development itself.

## Preferred parallel execution shape

Use no more workers than the work justifies. Typical maximum active durable writers: 2–3.

Example independent verticals:

1. Android/Gecko/Pigeon-facing implementation and focused tests.
2. Flutter/state/UI implementation and focused tests.
3. Independent verification/CI analysis or a genuinely separate product surface.

One owner per write surface. Shared interfaces, generated files, lockfiles, schemas, and full gates are serialized at the actual write/integration point.

## Coordination operating rules

- Reuse an existing suitable task before creating another.
- All coordinated writers use the same primary checkout/current branch; do not create/switch branches or worktrees merely for Coordinator parallelism unless the surrounding task explicitly authorizes that isolation.
- Path overlap is an advisory warning; stop only for a real same-file/hunk/write collision.
- Exclusive actions are narrow and exact; do not use broad integration locks.
- The Coordinator is not a background daemon, scheduler, heartbeat, or transcript store.
- Completion is accepted only after fresh integrated verification.

## Immediate next engineering action

**Revalidate AI-1 Quality against the exact current `weblibre-ua-mainline-v3` source before changing `browser_tool_executor.dart`.**

Decision rule:

- If current source compiles and focused AI-1 tests pass: do not patch the executor; advance to the next verified product/runtime gate, with Android Scenario 1 remaining the active blocker for the UA vertical.
- If current source still reproduces the executor compile error: make the smallest return-path fix, add/retain focused regression coverage, run focused verification, inspect the diff, and commit.
- Do not revive the historical fix solely because the old run failed.

## State-update contract

After each real milestone, update the appropriate project-state document with:

- project/repository
- branch
- exact HEAD
- PR and exact current head SHA
- last verified product checkpoint
- latest relevant CI/build/artifact
- last completed step
- unfinished step
- first next step
- Android runtime status
- files changed at the milestone
- last commit
- state docs updated
- product observations
- privacy-audit status
- material blockers/risks

Keep this file as a concise continuity contract; do not turn it into a transcript.

## Current checkpoint note

This file is a durable checkpoint created after reconciling the actual repository/branch state. The next agent must verify the refs again rather than assuming this SHA remains current after any later commit.
