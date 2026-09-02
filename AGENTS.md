# WebLibre — Agent Operating Contract

Before any WebLibre work, read:
1. `docs/WEBLIBRE_AI_COORDINATION_AND_CONTINUITY_2026-09-02.md`
2. `docs/WEBLIBRE_USER_OPERATING_RULES_2026-09-02.md`
3. `docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
4. `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
5. `docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md`

## Mandatory execution cadence

- Continue productive work for as long as the current session can execute it; do not stop merely because one task is blocked.
- When blocked, move to the highest-priority independent work that is safe under the dependency graph.
- Parallelize genuinely independent work when useful; avoid write collisions and serialize shared interfaces, generated files, lockfiles, schemas, and final gates.
- Use YAGNI and the shortest reliable path.
- Do not repeatedly install/download APKs. Treat physical Android validation as a late consolidated gate after source/CI/review/reachability work is sufficiently complete.
- Do not interrupt productive execution with progress messages merely to report discoveries/problems. Analyze, fix, reprioritize, and continue internally.
- Do not send a user update before a substantial work cycle; prefer approximately 10 minutes of productive work when the session permits, without fabricating time or activity.
- Each update must be concise: completed now; new blocker/problem if any; project-wide position; single next step.
- Do not ask for confirmation when repository evidence already justifies the next action, unless explicit permission or a safety boundary requires it.
- If a higher-priority dependency appears, replan and act automatically.

## Evidence and continuity

GitHub refs/code/CI/runtime evidence outrank stale docs and chat memory. Never claim runtime evidence without an actual Android observation. At each material milestone, update durable project state and commit it.
