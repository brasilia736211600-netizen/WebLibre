# WebLibre — Durable Resume Protocol

**Purpose:** allow any new chat, agent, or model to resume the project without relying on conversation memory.

## Source of truth

The repository itself is authoritative. Never infer project state from chat history when GitHub can verify it.

Canonical documents:
- `docs/WEBLIBRE_MASTER_PROJECT_MAP_2026-08-30.md`
- `docs/WEBLIBRE_WORKFLOW_STATE_2026-08-29.md`
- `docs/WEBLIBRE_PERSONAL_AI_AGENT_SPEC_2026-08-29.md`
- `docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md`
- `docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md` for UA/profile/performance product scope

## Mandatory recovery sequence

```text
READ
  -> read MASTER_PROJECT_MAP
  -> read WORKFLOW_STATE
  -> read PERSONAL_AI_AGENT_SPEC when architecture/product scope is involved
  -> read ANDROID_RUNTIME_VALIDATION_CHECKLIST before device validation
  -> read UA_FINGERPRINT_PRODUCT_REQUIREMENTS when UA/profile/performance scope is involved

VERIFY
  -> read actual branch ref and HEAD
  -> inspect recent commits
  -> inspect current PR
  -> inspect latest relevant CI/build/release runs and their head_sha
  -> compare current HEAD with the last saved checkpoint
  -> verify artifacts/assets are attached to the exact intended run/checkpoint

RECONCILE
  -> treat GitHub code as truth
  -> identify documentation drift
  -> distinguish source-verified, CI-verified, Android-runtime-verified, and documented claims
  -> never treat [x] alone as runtime proof
  -> never treat a successful build as proof that a later workflow revision ran
  -> never treat an artifact ZIP as equivalent to separately published release assets
  -> preserve user-observed runtime failures as evidence until explicitly revalidated

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
- `ARTIFACT-VERIFIED`: the intended build run completed successfully and the expected artifact exists and is tied to the exact run/head being evaluated.
- `RELEASE-ASSET-VERIFIED`: the expected APK files are individually attached to the intended GitHub Release and their asset names/URLs have been verified.
- `DOCUMENTED`: recorded in project state only; not evidence by itself.

Never promote a lower evidence level to a higher one.

## CI / artifact / release anti-drift rule

A build result is valid only for the exact workflow revision and `head_sha` captured by that run.

For any build/release step, verify this chain before marking it complete:

```text
INTENDED CHANGE
    -> commit SHA
    -> workflow definition contains the change
    -> run uses intended branch/ref
    -> run.head_sha == intended SHA
    -> required job succeeds
    -> required step is SUCCESS, not SKIPPED
    -> expected artifact/release asset exists
    -> asset name/path/checksum matches expectation
```

If any link is missing, record the step as pending/partial and do not claim completion.

A successful older run must never be used to prove a workflow change introduced later.

## APK distribution rule

Validation builds must provide both ABI APKs as individually downloadable GitHub Release assets whenever the release-asset path is enabled:
- `app-stable-arm64-v8a-release.apk`
- `app-stable-armeabi-v7a-release.apk`

Do not require the user to unpack an artifact ZIP when direct release assets are available.

The current validation workflow should create a non-production GitHub prerelease containing these APK assets without publishing to Google Play.

The final production/stable release must continue using the existing `v*` release path and should publish both split-ABI APKs plus the App Bundle only after the browser foundation has passed Android runtime validation and release validation.

A validation artifact ZIP and direct Release assets may coexist; they are not equivalent evidence. Verify each requested distribution surface explicitly.

## Runtime product-observation rule

User-observed behavior from real-device testing is evidence and must be recorded even when it does not yet establish root cause. In particular:
- container/tab restoration and per-container UA correctness are separate assertions;
- perceived performance/heaviness is an observation requiring measurement before optimization;
- unnecessary page reloads require diagnosis of restore/session/cache/engine-session behavior before implementation changes;
- desired UA/profile capabilities should be captured as requirements before implementation.

## Anti-amnesia rules

1. Never trust a remembered HEAD. Re-read the branch ref.
2. Never trust a PR description's old HEAD. Re-read the PR/branch.
3. Never use a CI result unless `head_sha` matches the checkpoint under evaluation.
4. Never repeat work merely because a new conversation cannot remember it.
5. Before changing anything, compare the current repository against the saved state.
6. When a task is completed, save the exact result, tested SHA, CI/build run, and next step in the durable state document.
7. When a task is partially completed, record the precise boundary and the remaining blocker.
8. If new evidence contradicts the state document, update the state first, then continue.
9. Do not introduce architecture changes without focused test/runtime evidence that the existing architecture is insufficient.
10. At each material milestone, update both the master map and workflow state, then commit them.
11. When a workflow definition is changed, do not use any run created before that workflow change as proof of the new behavior.
12. When an asset/release step is requested, verify the actual asset/release object rather than inferring it from logs.
13. Keep product requirements separate from implementation commitments; do not implement every benchmark feature without checking engine capability and YAGNI.
14. Before removing features for size/performance reasons, measure actual APK contribution and runtime cost.

## What every handoff must contain

```text
PROJECT: WebLibre
BRANCH: <actual branch>
HEAD: <actual HEAD>
PR: <number/state/base>
LAST VERIFIED PRODUCT CHECKPOINT: <sha>
LAST CI: <run id/number + status + exact head_sha>
LAST BUILD: <run id/number + status + exact head_sha>
LAST ARTIFACT: <artifact/release id + asset status>
LAST COMPLETED STEP: <one precise sentence>
UNFINISHED STEP: <one precise sentence>
FIRST NEXT STEP: <one precise sentence>
ANDROID RUNTIME STATUS: <verified/pending + exact scenarios>
FILES CHANGED AT LAST MILESTONE: <paths>
LAST COMMIT: <sha + message>
STATE DOCS UPDATED: <yes/no + commit>
PRODUCT OBSERVATIONS: <measured/unmeasured observations and source>
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
5. docs/WEBLIBRE_ANDROID_RUNTIME_VALIDATION_CHECKLIST_2026-08-30.md قبل اختبار Android
6. docs/WEBLIBRE_UA_FINGERPRINT_PRODUCT_REQUIREMENTS_2026-08-31.md عند مناقشة أو تنفيذ UA/profile/performance

ثم نفّذ:
READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE

VERIFY فعليًا من GitHub:
- branch وHEAD الحاليان
- آخر commits
- PR الحالي وحالته وhead_sha
- آخر Quality/CI/build/release runs وhead_sha لكل run
- أي commits أو تغييرات بعد آخر state/map
- artifacts وGitHub Release assets المطلوبة، إن وجدت

لا تعتبر [x] أو source-verified أو CI success أو build success دليلًا على Android runtime.
ولا تعتبر artifact ZIP دليلًا على وجود direct Release assets.
ميّز دائمًا بين:
SOURCE-VERIFIED
CI-VERIFIED
ANDROID-RUNTIME-VERIFIED
ARTIFACT-VERIFIED
RELEASE-ASSET-VERIFIED
DOCUMENTED

لكل CI/build/release خطوة، لا تعتبرها مكتملة إلا بعد التحقق من السلسلة:
commit SHA -> workflow revision -> run head_sha -> job SUCCESS -> required step SUCCESS (وليس SKIPPED) -> expected artifact/release asset.

استخرج فقط:
- آخر خطوة مكتملة ومثبتة
- آخر خطوة غير مكتملة
- أول خطوة تالية فقط

لا تعِد أي عمل سبق إثباته.
لا تضف architecture جديدة إلا إذا أثبت test/runtime أن الحالية غير كافية.
التزم بـYAGNI وبترتيب الاعتماديات.

سجّل أدلة Android الحقيقية كما هي، بما فيها الفشل والملاحظات غير المقاسة؛ لا تحول الملاحظة إلى سبب جذري دون تحقق.

عند كل milestone مادي:
- حدّث MASTER_PROJECT_MAP
- حدّث WORKFLOW_STATE
- حدّث الوثيقة المتخصصة المتأثرة إن وجدت
- سجّل HEAD وCI/build/release والأدلة والاختبارات والـnext step
- نفّذ commit واضح

إذا كان المطلوب توزيع APKs مباشرة، تحقق من وجود:
- app-stable-arm64-v8a-release.apk
- app-stable-armeabi-v7a-release.apk
كـGitHub Release assets منفصلة، ولا تكتفِ بوجود ZIP artifact.

في النسخ الإنتاجية المستقرة مستقبلًا، استخدم مسار v* الموجود للنشر الفعلي بعد اكتمال Android runtime + release validation، مع APKs للـABIs وAAB.

عند تقييم UA/profile، لا تكتفِ بتغيير raw UA string: افحص اتساق OS/browser/version/display/locale/network والحقول التي يستطيع المحرك فعليًا التحكم بها. اقرأ وثيقة UA_FINGERPRINT_PRODUCT_REQUIREMENTS قبل التصميم.

إذا كان الادعاء متعلقًا بالأداء أو إعادة تحميل الصفحات، قِس أولًا cold start/memory/reload/session/cache/engine-session behavior وAPK composition قبل إزالة أي ميزة.

إذا وجدت تعارضًا بين الذاكرة/الرسائل والـrepository، فالـrepository هو الحقيقة.
إذا كانت نتيجة CI/build/release لا تطابق HEAD المقصود، لا تستخدمها كدليل للـHEAD الحالي.

ابدأ بالتحقق من الحالة الفعلية، ثم نفّذ أول خطوة تالية فقط.
```
