# WebLibre — Durable Resume Protocol

**Purpose:** allow any new chat, agent, or model to resume the project without relying on conversation memory.

## Source of truth

The repository itself is authoritative. Never infer project state from chat history when GitHub can verify it.

Canonical documents:
- `docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`

## Mandatory recovery sequence

```text
READ
  -> read MASTER_PROJECT_MAP
  -> read WORKFLOW_STATE
  -> read PERSONAL_AI_AGENT_SPEC when architecture/product scope is involved

VERIFY
  -> read actual branch ref and HEAD
  -> inspect recent commits
  -> inspect current PR
  -> inspect latest relevant CI runs and their head_sha
  -> compare current HEAD with the last saved checkpoint

RECONCILE
  -> treat GitHub code as truth
  -> identify documentation drift
  -> distinguish source-verified, CI-verified, and Android-runtime-verified claims
  -> never treat [x] alone as runtime proof

PLAN
  -> identify exactly one first next step
  -> preserve dependency order and YAGNI

EXECUTE
TEST
DIFF
COMMIT
SAVE STATE

Then repeat the cycle at every material milestone.
```

## Evidence levels

Use these labels precisely:

- `SOURCE-VERIFIED`: code path inspected in the repository.
- `CI-VERIFIED`: a relevant CI run completed successfully and its `head_sha` exactly matches the checkpoint being evaluated.
- `ANDROID-RUNTIME-VERIFIED`: behavior was exercised on a real Android runtime/device.
- `DOCUMENTED`: recorded in project state only; not evidence by itself.

Never promote a lower evidence level to a higher one.

## Anti-amnesia rules

1. Never trust a remembered HEAD. Re-read the branch ref.
2. Never trust a PR description's old HEAD. Re-read the PR/branch.
3. Never use a CI result unless `head_sha` matches the checkpoint under evaluation.
4. Never repeat work merely because a new conversation cannot remember it.
5. Before changing anything, compare the current repository against the saved state.
6. When a task is completed, save the exact result, tested SHA, CI run, and next step in the durable state document.
7. When a task is partially completed, record the precise boundary and the remaining blocker.
8. If new evidence contradicts the state document, update the state first, then continue.
9. Do not introduce architecture changes without focused test/runtime evidence that the existing architecture is insufficient.
10. At each milestone, update both the master map and workflow state, then commit them.

## Current known checkpoint at creation

- Branch: `weblibre-ua-mainline-v3`
- HEAD at protocol creation: `a5c2c1e1da5b9af8057f3de6bba113f388c6e183`
- PR: `#3`, open, draft, base `main`
- Browser foundation: source-verified; real Android cold-start/restore, Container A/B isolation, and proxy A/B/fail-closed remain runtime pending.
- AI-1: six-tool contract/registry, source-verified mappings, minimal execution boundary, and focused tests implemented; current-head CI validation remains pending.
- First next action: inspect current Quality run(s) and accept a result only when its `head_sha` matches the actual current branch HEAD.

## What every handoff must contain

```text
PROJECT: WebLibre
BRANCH: <actual branch>
HEAD: <actual HEAD>
PR: <number/state/base>
LAST VERIFIED PRODUCT CHECKPOINT: <sha>
LAST CI: <run id/number + status + exact head_sha>
LAST COMPLETED STEP: <one precise sentence>
UNFINISHED STEP: <one precise sentence>
FIRST NEXT STEP: <one precise sentence>
ANDROID RUNTIME STATUS: <verified/pending + exact scenarios>
FILES CHANGED AT LAST MILESTONE: <paths>
LAST COMMIT: <sha + message>
STATE DOCS UPDATED: <yes/no + commit>
```

## Copy/paste resume command

Use this as the first message when starting a new chat or handing the project to another agent:

```text
@GitHub @Thinking
استأنف مشروع WebLibre من GitHub، ولا تعتمد على ذاكرة الدردشة.

اقرأ بالترتيب:
1. docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md
2. docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md
3. docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md
4. docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md

ثم نفّذ:
READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE

VERIFY فعليًا من GitHub:
- branch وHEAD الحاليان
- آخر commits
- PR الحالي وحالته وhead_sha
- آخر Quality/CI runs وhead_sha لكل run
- أي commits أو تغييرات بعد آخر state/map

لا تعتبر [x] أو source-verified أو CI success دليلًا على Android runtime.
ميّز دائمًا بين:
SOURCE-VERIFIED
CI-VERIFIED
ANDROID-RUNTIME-VERIFIED
DOCUMENTED

استخرج فقط:
- آخر خطوة مكتملة ومثبتة
- آخر خطوة غير مكتملة
- أول خطوة تالية فقط

لا تعِد أي عمل سبق إثباته.
لا تضف architecture جديدة إلا إذا أثبت test/runtime أن الحالية غير كافية.
التزم بـYAGNI وبترتيب الاعتماديات.

عند كل milestone مادي:
- حدّث MASTER_PROJECT_MAP
- حدّث WORKFLOW_STATE
- سجّل HEAD وCI والأدلة والاختبارات والـnext step
- نفّذ commit واضح

إذا وجدت تعارضًا بين الذاكرة/الرسائل والـrepository، فالـrepository هو الحقيقة.
إذا كانت نتيجة CI لا تطابق HEAD، لا تستخدمها كدليل للـHEAD الحالي.
لا تبدأ خطوة لاحقة فقط لأن خطوة سابقة تبدو [x]؛ أثبتها بمستوى الدليل المناسب.

ابدأ بالتحقق من الحالة الفعلية، ثم نفّذ أول خطوة تالية فقط.
```