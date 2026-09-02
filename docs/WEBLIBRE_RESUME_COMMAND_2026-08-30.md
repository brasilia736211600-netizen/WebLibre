# WebLibre — Durable Resume Protocol

**Purpose:** allow any new ChatGPT/Codex/agent session to resume WebLibre from repository evidence without relying on conversation memory or repeated user explanation.

## Source of truth

Use this precedence:

`CURRENT GITHUB REPO / CI / RUNTIME EVIDENCE`
`>` `COMMITTED PROJECT-STATE DOCS`
`>` `CHAT MEMORY`

Never treat memory as stronger than current repository evidence.

## Mandatory recovery sequence

```text
READ
  -> continuity checkpoint
  -> master project map
  -> workflow state
  -> AI specification when product/architecture scope matters
  -> Android runtime checklist before device validation
  -> UA requirements/forensics for UA/profile/restore scope
  -> privacy audit for privacy/network/identity/permissions scope

VERIFY
  -> actual branch + HEAD
  -> recent commits
  -> PR + live head_sha
  -> relevant CI/build/release runs + exact head_sha
  -> artifacts/release assets when applicable
  -> compare against saved checkpoint

RECONCILE
  -> GitHub code/refs are authoritative
  -> classify claims as SOURCE-VERIFIED / CI-VERIFIED / ANDROID-RUNTIME-VERIFIED / ARTIFACT-VERIFIED / RELEASE-ASSET-VERIFIED / DOCUMENTED
  -> update stale state before making decisions

PLAN
  -> identify exactly one first bounded NEXT step
  -> preserve dependency order and YAGNI

EXECUTE
TEST
DIFF
COMMIT
SAVE STATE

Repeat at every material milestone.
```

## Anti-amnesia / anti-drift rules

1. Never trust a remembered HEAD; re-read the branch ref.
2. Never trust an old PR description's HEAD; re-read the PR.
3. A CI result is valid only when its `head_sha` exactly matches the checkpoint being evaluated.
4. Never repeat completed work merely because a new session cannot remember it.
5. Never reapply a historical fix without reproducing the current defect.
6. Never turn `[x]` or `DOCUMENTED` into runtime evidence.
7. Never use an old successful build to prove a later workflow revision.
8. Never treat an artifact ZIP as equivalent to individually published GitHub Release assets.
9. Preserve real-device observations, including failures, until revalidated.
10. Do not introduce new architecture unless focused evidence proves the current design insufficient.
11. Do not broad-clean or erase unrelated user changes.
12. Do not manually edit generated Pigeon/Drift outputs unless the repository generation workflow requires it.

## Evidence levels

- `SOURCE-VERIFIED`: repository code/path inspected.
- `CI-VERIFIED`: relevant CI run succeeded with exact matching `head_sha`.
- `ANDROID-RUNTIME-VERIFIED`: real Android device/runtime evidence.
- `ARTIFACT-VERIFIED`: intended build artifact exists and is tied to exact run/head.
- `RELEASE-ASSET-VERIFIED`: intended APK is individually attached to the intended GitHub Release and verified.
- `DOCUMENTED`: recorded state only.

Never promote one level without the evidence required for the next.

## AI engineering stack — use automatically when relevant

### Canonical/core
- **GitHub:** always the repository/ref/PR/CI/release evidence source.
- **get-fable:** lifecycle routing for discover/plan/execute/verify/recover/handoff/release when useful.
- **fable-handoff:** compact durable session state at handoff/pause points.

### Autonomous execution and verification
- **fable-cowork:** bounded multi-step autonomous execution for complex goals; never treat as unlimited background work.
- **fable-loop:** bounded polling for CI/build/status with timeout/backoff; never infinite polling.
- **fable-discover:** load-bearing repository/environment/runtime discovery before planning.
- **fable-plan:** bounded testable work cards for multi-file/architectural tasks.
- **fable-execute:** one accepted bounded implementation card.
- **fable-verify:** fresh machine-checked acceptance evidence.
- **fable-recover:** repeated failures, stale caches, branch drift, contradictory evidence.

### Engineering/review
- **Codex Engineering Guardrails:** smallest reliable change, root-cause analysis, focused-to-broad verification.
- **Codex Process Jobs:** long-running local builds/tests/benchmarks/downloads.
- **Codex Coordinator:** only for genuinely independent parallel verticals, usually 2–3 maximum.
- **CodeRabbit:** independent review after a meaningful code slice; not a replacement for tests/CI.
- **Codex Advisor:** one-shot second opinion only for material unsettled architecture/interface/concurrency/security decisions.
- **AI DevKit:** agent management/communication/orchestration, TDD, structured debugging, verification, review, and security when the task needs them.
- **fable-review / fable-security:** independent code/review/security passes when materially relevant.
- **PR-completion / review-triage skills:** use when shepherding a PR through CI/reviews/conflicts/readiness.

### Memory and prompt handling
- **Yaps Memory:** preferred durable knowledge layer for reusable verified facts and decisions.
- **AI DevKit memory:** use only when a separate local memory layer is genuinely required; do not create competing canonical memories.
- **Prompt Optimizer:** only for long/complex requests where an execution brief materially improves routing.

### Plugin-only
- **Plugin Autopilot:** do not use for normal WebLibre application work; use only when the task itself is plugin development/packaging/submission/publishing.

## Capability boundary

A documented skill is an operating rule, not proof that the current session exposes that tool or permission.

When a needed capability is unavailable:
1. do not invent the result;
2. record the exact blocker;
3. continue dependency-safe independent work;
4. record the precise next manual action in durable state.

For GitHub Actions, `workflow_dispatch` in YAML proves only that the workflow supports dispatch; it does not prove the current session has dispatch permission/tooling.

## Parallelism

Default to one task. Use 2–3 durable writers only when substantial verticals are truly independent. One owner per write surface. Shared interfaces/generated files/lockfiles/schemas/full gates are serialized at the real integration point.

## WebLibre product gates

### AI-1 browser tools

```text
get_tabs
get_current_tab
create_tab
switch_tab
close_tab
open_url
```

Do not start AI-2 Agent Core, provider integration, memory architecture, remote gateway, or autonomous workflows until the AI-1/browser foundation gates are satisfied.

### UA / restore

Scenario 1 is the active Android runtime gate. Do not spend runtime effort on later scenarios until Scenario 1 passes.

Do not bypass the blocker with:
- global Gecko UA
- freshness heuristics
- second persistence DB
- new recovery Pigeon field
- `RecoverableTab.userAgent`
- Android Components fork

Do not equate `await syncEvents()` or `_freshSnapshotPending` with proof of a fresh snapshot.

### Privacy

Maintain:

`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

Distinguish silent app-level collection/transmission from user-directed browsing/search/feed/proxy/Tor/sharing traffic.

### Release

For split-ABI distribution, verify the individually published APK assets:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

A ZIP artifact is not a substitute for direct Release assets. Production/stable release remains gated by browser runtime and release validation.

## State-update contract

At every material milestone update the Master Map, Workflow State, and affected specialized document with:

`PROJECT`
`BRANCH`
`HEAD`
`PR + head_sha`
`LAST VERIFIED CHECKPOINT`
`LAST CI / BUILD / ARTIFACT`
`LAST COMPLETED STEP`
`UNFINISHED STEP`
`FIRST NEXT STEP`
`ANDROID RUNTIME STATUS`
`FILES CHANGED`
`LAST COMMIT`
`STATE DOCS UPDATED`
`PRODUCT OBSERVATIONS`
`PRIVACY AUDIT STATUS`
`BLOCKERS / RISKS`

Keep state concise; never turn it into a transcript.

## Final copy/paste resume command

```text
@GitHub @Thinking

استأنف مشروع WebLibre من الحالة الفعلية للمستودع، ولا تعتمد على ذاكرة الدردشة السابقة.
لا تطلب مني شرح ما سبق، ولا تسأل أين توقفنا. استنتج نقطة التوقف من GitHub وملفات الحالة ثم واصل التنفيذ.

اقرأ أولًا:
1. docs/WEBLIBRE_AI_COORDINATION_AND_CONTINUITY_2026-09-02.md
2. docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md
3. docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md
4. docs/WEBLIBRE_RESUME_COMMAND_2026-08-30.md
ثم اقرأ فقط الوثائق المتخصصة ذات الصلة بالمهمة التالية.

تحقق فعليًا من GitHub:
- branch
- exact HEAD
- recent commits
- PR + head_sha
- أحدث CI/build/release runs + head_sha
- artifacts/release assets عند الحاجة
- أي تغييرات بعد آخر checkpoint

طبّق:
READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE

استخرج داخليًا:
COMPLETED / VERIFIED
IN PROGRESS
BLOCKED
NEXT

لا تعِد العمل المكتمل، ولا تعالج مشكلة قديمة دون دليل جديد، ولا تنشئ architecture لمجرد الاحتياط، ولا تنتظر Android إذا أمكن التقدم عبر source/CI.

استخدم منظومة الأدوات الموثقة تلقائيًا حسب الحاجة:
GitHub, get-fable, fable-discover, fable-plan, fable-execute, fable-verify, fable-recover, fable-handoff, fable-cowork, fable-loop, Codex Engineering Guardrails, Codex Process Jobs, Codex Coordinator, CodeRabbit, Codex Advisor, AI DevKit, Yaps Memory, Prompt Optimizer, PR-completion/review/security skills.
لا تستخدم Plugin Autopilot في WebLibre إلا إذا أصبحت المهمة نفسها تطوير Plugin.
لا تستخدم كل الأدوات لمجرد وجودها؛ استخدم أصغر مجموعة مفيدة.

إذا كانت أداة أو صلاحية لازمة غير متاحة في الجلسة:
لا تخترع النتيجة؛ وثّق blocker بدقة، وواصل كل عمل مستقل لا يخالف الاعتماديات، وسجّل الإجراء اليدوي التالي في الحالة.

لا تبدأ AI-2 قبل إغلاق AI-1 ومتطلبات browser foundation.
Scenario 1 الخاص بـUA/restore هو بوابة Android الحالية؛ لا تنتقل إلى السيناريوهات اللاحقة قبل اجتيازه.

عند كل milestone مادي:
حدّث MASTER_PROJECT_MAP وWORKFLOW_STATE والوثيقة المتخصصة المتأثرة، وسجّل exact HEAD وCI/build/runtime evidence والـNEXT التالي ثم commit.

واصل العمل إلى أقصى حد ممكن دون تدخلي، وانتقل تلقائيًا إلى NEXT التالي عندما يصبح مبررًا، بدل التوقف لطلب إذن.
```
