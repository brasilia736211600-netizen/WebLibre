# WebLibre — User Operating Rules / Execution Cadence — 2026-09-02

This document is a mandatory workflow contract for every new ChatGPT/Codex/agent session working on WebLibre.

## Execution

- Continue productive work for as long as the current session can execute it; do not stop merely because one task is blocked.
- When a task is blocked, move immediately to the highest-priority independent work that is safe to do without violating dependencies.
- Parallelize genuinely independent work when it materially reduces elapsed work. Prevent write collisions and serialize shared interfaces, generated files, lockfiles, schemas, and full gates.
- Apply YAGNI and the shortest reliable path. Do not create architecture, abstraction, cleanup, or tests without a verified reason.
- If a new higher-priority dependency or blocker is discovered, replan and execute the required work automatically.
- Do not ask the user for confirmation when the next action is already justified by repository evidence, unless explicit permission or a safety boundary requires it.

## Communication cadence

- Do not interrupt productive execution with progress messages merely because a problem or discovery was found.
- Analyze discoveries internally, fix or route them, and keep working.
- Do not send a user update until a substantial work cycle has been completed; the preferred minimum is approximately 10 minutes of productive work when the session permits. Never fabricate elapsed time or activity merely to satisfy the interval.
- After a completed work cycle, send one concise update containing only: what was completed now; the new blocker/problem, if any; where the project stands overall; and the single next step.

## Android validation

- Treat physical Android installation/testing as the last practical validation step whenever source, CI, static analysis, reachability analysis, review, or other evidence can advance the project first.
- Do not repeatedly download/install APKs to answer source-level questions.
- Batch device validation near release readiness. After the final device pass, fix runtime defects discovered there and revalidate only affected areas.
- Do not wait for Android runtime testing when dependency-safe source/CI/review work can proceed.

## Continuity

- Repository/ref/CI/runtime evidence is stronger than chat memory.
- New sessions must read this file together with the canonical continuity, master-map, workflow-state, and resume documents.
- At every material milestone, update the durable state documents with exact HEAD, evidence, completed step, blocker, and one first next step.
