# WebLibre AI Coordination & Continuity Checkpoint — 2026-09-02

## Purpose

This file is the durable cross-chat / cross-agent continuity checkpoint for the WebLibre project. It prevents the next Codex session or agent from depending on conversational memory. GitHub repository state, commit SHAs, PR refs, CI runs, and committed project-state documents are authoritative.

## Authoritative repository state at checkpoint creation

- Repository: `brasilia736211600-netizen/WebLibre`
- Working branch: `weblibre-ua-mainline-v3`
- HEAD at prior checkpoint: `54434b795844d5b915fc72fa9f4e793577cf6202`
- Open PR: `#3`
- PR title: `feat(containers): complete per-container User-Agent vertical slice`
- PR base: `main`
- Current refs must always be re-read; this section is historical checkpoint context, not a trusted live ref.

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
- The current `browser_tool_executor.dart` contains an explicit terminal failure return after the dispatch switch; do not reapply the historical missing-return patch without fresh evidence.
- Current Quality CI must still be proven against the exact live HEAD before AI-1 is promoted to `CI-VERIFIED`.

### Agent Core

- AI-2 / broader Agent Core work has **not started** and should remain downstream of AI-1 and the browser runtime contract being sufficiently proven.

### Privacy

- Privacy hardening has substantial source work but outstanding cleanup/audit items remain. Do not declare privacy complete without current source/CI evidence.
- Re-check background-feed fetching, dead account-sync paths, and outbound endpoint/data-flow coverage before release claims.

## Engineering invariants / non-negotiables

- YAGNI: do the smallest change that closes the current verified gap.
- Evidence precedence: current repository/CI/runtime evidence > stale documents > conversation memory.
- Maintain the evidence chain:
  `SOURCE-VERIFIED → CI-VERIFIED → ANDROID-RUNTIME-VERIFIED → ARTIFACT-VERIFIED → RELEASE-ASSET-VERIFIED`.
- Never equate `await syncEvents()` with proof a fresh snapshot was consumed.
- Never use `_freshSnapshotPending` as a freshness proof; stale debounced events and separate RPC/event timing make arrival order insufficient.
- Do not modify generated Pigeon/Drift artifacts manually unless the repository's generation workflow explicitly requires it.
- Do not erase unrelated user work or broad-clean the checkout.
- Do not claim tests/builds/runtime behavior from reasoning or old logs; use fresh evidence.

## AI engineering tool stack and role boundaries

Use the smallest useful set. Tool availability never overrides repository evidence or required approvals.

### Core execution / continuity

- **GitHub:** canonical repo/ref/PR/CI/release evidence; always use for resume verification.
- **get-fable:** route lifecycle work, discover, plan, execute, verify, recover, handoff, and release tasks when its deterministic routing adds value.
- **fable-cowork:** autonomous multi-step tool chaining for complex bounded goals; never treat it as an unlimited background worker.
- **fable-loop:** bounded polling/watch loops for async CI/build/test status; use with explicit timeout/backoff, never infinite polling.
- **fable-discover:** gather the smallest repository/environment/runtime evidence before planning when load-bearing facts are unknown.
- **fable-plan:** convert discovery into bounded, testable work cards for complex multi-file or architectural tasks.
- **fable-execute:** execute one accepted bounded work card with immediate verification.
- **fable-verify:** obtain fresh machine-checked acceptance evidence before completion claims.
- **fable-recover:** diagnose repeated failures, stale caches, branch drift, or contradictory evidence before further edits.
- **fable-handoff:** create compact durable continuation state at session boundaries.
- **fable-review:** independent diff/spec review before merge when useful.
- **fable-security:** threat modeling and security review for trust boundaries, auth, AI, network, or sensitive data work.
- **fable-release:** release/merge readiness only after fresh verification.

### Parallelism / long-running work

- **Codex Coordinator:** goal-scoped coordination and collision avoidance for genuinely independent verticals.
- **Codex Process Jobs:** durable detached local builds/tests/benchmarks/downloads when the underlying work may run long.
- **AI DevKit agent-management / communication / orchestration:** only when there are real multi-agent dependencies; do not create workers for trivial commands.

### Engineering verification / quality

- **Codex Engineering Guardrails:** smallest reliable implementation, root-cause analysis, focused-to-broad verification.
- **AI DevKit TDD / structured-debug / verify / security-review / simplify:** use only for the relevant engineering need.
- **CodeRabbit:** independent review after a meaningful code slice; not a replacement for local tests or GitHub CI.
- **Codex Advisor:** one-shot second opinion for material architecture/interface/concurrency/security decisions; skip settled/mechanical edits.

### Memory / prompt handling

- **Yaps Memory:** preferred durable project knowledge layer for reusable facts/decisions; never store transcripts, secrets, or volatile command logs.
- **AI DevKit memory:** use only if a separate local memory layer is needed by the active task; avoid creating two competing canonical memory stores.
- **Prompt Optimizer:** use only for long/complex user requests when converting them into an execution brief materially improves routing.

### Plugin-only tooling

- **Plugin Autopilot:** outside normal WebLibre application implementation. Use only when the task itself is Plugin development, packaging, validation, submission, or publishing.

## Parallel execution rules

Use no more workers than the work justifies. Typical maximum active durable writers: 2–3.

Example independent verticals:
1. Android/Gecko/Pigeon-facing implementation and focused tests.
2. Flutter/state/UI implementation and focused tests.
3. Independent verification/CI/security analysis or a genuinely separate product surface.

One owner per write surface. Shared interfaces, generated files, lockfiles, schemas, and full gates are serialized at the actual write/integration point.

## Coordination operating rules

- Reuse an existing suitable task before creating another.
- All coordinated writers use the same primary checkout/current branch; do not create/switch branches or worktrees merely for Coordinator parallelism unless explicitly authorized.
- Path overlap is advisory; stop only for a real same-file/hunk/write collision.
- Exclusive actions are narrow and exact.
- Coordinator is not a background daemon, scheduler, heartbeat, or transcript store.
- Process Jobs are not a reason to claim a result before retrieving and checking the result.
- Completion is accepted only after fresh integrated verification.

## Capability/permission boundary

A skill documented here describes the intended operating role, not an entitlement to unavailable tools or permissions. If a needed capability is unavailable in the current ChatGPT/Codex session:

1. do not invent the result;
2. record the blocker precisely;
3. continue with independent work that does not violate dependencies;
4. leave the exact manual/next action in durable state.

For GitHub Actions, a workflow definition containing `workflow_dispatch` does not prove the current session can dispatch it. Never substitute an old CI run for a missing current-head run.

## Immediate next engineering action

**Revalidate AI-1 Quality against the exact current `weblibre-ua-mainline-v3` source before changing `browser_tool_executor.dart`.**

Decision rule:

- If current source compiles and focused AI-1 tests pass: do not patch the executor; advance to the next verified product/runtime gate, with Android Scenario 1 remaining the active blocker for the UA vertical.
- If current source still reproduces an executor compile error: make the smallest return-path fix, add/retain focused regression coverage, run focused verification, inspect the diff, and commit.
- Do not revive the historical fix solely because the old run failed.

## State-update contract

After each real milestone, update the appropriate project-state document with:

- project/repository
- exact branch and HEAD
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