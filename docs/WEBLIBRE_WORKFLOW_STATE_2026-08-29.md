# WebLibre — Durable Workflow State

**Last synchronized:** 2026-09-02
**Branch:** `weblibre-ua-mainline-v3`
**Current HEAD at this documentation milestone:** `d781abc958cd4b5c4cdc729326fdba055c4e8820`

## Source of truth
GitHub code, refs, commits, PRs, CI/build/release runs, artifacts and release assets are authoritative. Chat memory and `[x]` markers are not evidence.

## Verified current checkpoint
- PR #3 remains OPEN and DRAFT, base `main`; its live `head_sha` must be re-read on every resume.
- The branch advanced through documentation-only continuity commits after the prior `eea4b40...` source checkpoint.
- Flutter CICD `33420348298`, job `99580917046`: SUCCESS on exact source checkpoint `eea4b40...`.
- No Quality run has been verified for the newer documentation HEAD `d781abc...`.
- The current Quality workflow contains AI-1 registry/executor tests and targeted container/native tests.

## Browser / Android runtime
Scenario 1 remains **FAIL**:
- Container A restored.
- Tab restored.
- Before process death: configured Chrome/120 UA observed.
- After relaunch: restored navigation observed Gecko/Firefox 152 UA.
- No `Resume last tab` control was present in that post-relaunch state.

Do not run Scenarios 2–6 until Scenario 1 passes.

## AI-1
Six-tool model-independent Browser Tool slice:
`get_tabs`, `get_current_tab`, `create_tab`, `switch_tab`, `close_tab`, `open_url`.

Contracts, registry, executor, source mappings and focused tests are SOURCE-VERIFIED. The current `browser_tool_executor.dart` includes a terminal fallback return after dispatch; do not reapply the historical missing-return patch without new evidence. Current Quality CI proof remains pending.

## Privacy / personal-product hardening
The existing privacy/account source boundary remains SOURCE-VERIFIED with Flutter build verification on exact checkpoint `eea4b40...`. Documentation-only commits after that checkpoint do not extend build evidence to the new HEAD.

Still pending: automatic background feed fetch removal, dead-source/reachability audit, outbound endpoint/background-service audit, permission/cleartext minimization review, local privacy/data-flow screen, and Android UA Scenario 1 root-cause fix/revalidation.

## AI orchestration stack
The project continuity protocol now records a tiered tool stack instead of requiring every tool for every task.

**Always/canonical:** GitHub for repository evidence; get-fable for lifecycle routing when useful.

**Execution/verification as needed:** fable-discover, fable-plan, fable-execute, fable-verify, fable-recover, fable-handoff, fable-review, fable-security, fable-release, and fable-cowork/fable-loop for bounded autonomous chaining or async status polling.

**Engineering:** Codex Engineering Guardrails, AI DevKit TDD/structured-debug/verify/security-review, Codex Process Jobs for long-running local work.

**Parallelism/review:** Codex Coordinator for genuinely independent verticals; CodeRabbit for independent PR/diff review after meaningful changes; PR-completion review/triage skills when shepherding a PR through CI/review/merge readiness.

**Architecture:** Codex Advisor only for material unsettled architecture/interface/concurrency/security decisions.

**Memory/prompt:** Yaps Memory is the preferred durable knowledge layer; avoid competing canonical memory stores. Prompt Optimizer only for long/complex briefs.

**Plugin-only:** Plugin Autopilot remains outside ordinary WebLibre application implementation.

## Recommended autonomous operating pattern
For a complex bounded milestone:
`GitHub → get-fable-discover → get-fable-plan → Coordinator/delegate if independent work exists → fable-execute / Process Jobs → fable-verify → fable-review/security as applicable → commit → fable-handoff/save state`.

For async CI/status:
`GitHub → fable-loop` with bounded polling, timeout and backoff. Never run an infinite watcher.

For repeated failure:
`fable-recover` before another production-code edit.

## Capability boundary
A documented skill is an operating rule, not proof that the current ChatGPT/Codex session has that tool or permission. When a required capability is unavailable: do not invent a result; record the exact blocker; continue independent work when dependency-safe; preserve the exact next manual action in state.

## Last completed step
**Durable AI orchestration/continuity state updated and committed:** `d781abc958cd4b5c4cdc729326fdba055c4e8820`.

## Current unfinished step
**AI-1/current Quality CI verification remains incomplete on the live branch HEAD; no run with matching current `head_sha` is presently verified.**

## FIRST NEXT STEP — exactly one
**Obtain/verify a WebLibre Quality run whose `head_sha` exactly matches the live PR branch HEAD, then inspect AI-1 registry/executor, targeted container, and native test results before making any production-code change.**

## Mandatory loop
`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

At every material milestone update this state, the Master Map, and the affected specialized document with exact HEAD, evidence, tests/run IDs, blocker and one first next step.
