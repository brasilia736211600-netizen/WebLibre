# دليل تشغيل Genspark لمشروع WebLibre — خطوات تفصيلية جدًا وبأقل Credits

**التاريخ:** 2026-08-28

## 0) الهدف من هذا الدليل

هذا الملف هو دليل المستخدم خطوة بخطوة لتجهيز Genspark لمتابعة مشروع WebLibre من الحالة الحالية، مع حماية المستودع المرجعي وتقليل استهلاك Credits.

المصدر المرجعي الحالي:

`https://github.com/brasilia736211600-netizen/WebLibre`

الفرع الذي احتوى على أساس UA أثناء هذه المرحلة:

`weblibre-ua-mainline-v2`

> مهم: لا تجعل Genspark يعمل على المستودع المرجعي. المطلوب أن يعمل فقط على Fork جديد مستقل.

---

# 1) قبل فتح Genspark — جهّز GitHub

## الخيار المفضل

إذا كان Genspark قادرًا عبر موصل GitHub على إنشاء Fork، اطلب منه ذلك في أول مهمة كما هو موضح في Prompt هذا الدليل.

## الخيار الآمن إذا لم يملك Genspark صلاحية إنشاء Fork

أنشئ الـFork يدويًا في GitHub أولًا:

1. افتح:
   `https://github.com/brasilia736211600-netizen/WebLibre`
2. اضغط **Fork**.
3. اختر حساب GitHub الذي سيملك النسخة الجديدة.
4. سمِّها مثلًا:
   `WebLibre-Genspark-Work`
5. لا تحذف تاريخ Git.
6. بعد الإنشاء، تأكد أن الرابط الجديد مختلف عن المستودع المرجعي.
7. Genspark يجب أن يعمل داخل هذه النسخة الجديدة فقط.

لا تستخدم زر `Clone` لإنشاء نسخة عمل إذا كان هدفك حماية المستودع المرجعي؛ الـFork هو الفصل الواضح بين المرجع والتجارب.

---

# 2) إنشاء Hub في Genspark

Genspark Hub هو مساحة عمل دائمة تشارك الملفات والسياق بين المشاريع. الملفات المرفوعة في Hub يمكن إعادة استخدامها في محادثات متعددة داخله، ويمكن وضع Custom Instructions على مستوى الـHub. حدود Hub الحالية: حتى 100 ملف، و10MB لكل ملف. كما توصي Genspark بإبقاء الملفات قليلة لأن كثرتها ترفع استهلاك Credits. citeturn310437search0

من الشريط الجانبي:

**Hub → + New**

### الاسم

اكتب حرفيًا:

`WebLibre — Genspark Engineering Lab`

### Theme Color

اختر أي لون بسيط. اللون لا يؤثر على القدرة البرمجية؛ لا تضيع وقتًا في تخصيصه.

### Hub Description

ضع النص التالي حرفيًا:

```text
Engineering workspace for continuing the existing WebLibre Android browser project. The goal is to finish and harden independent per-container User-Agent and Proxy configuration, persistence, restoration, runtime isolation, settings UI, CI, and final APK validation without rewriting the project from scratch. The current/reference repository must never be modified; all experiments and commits must happen only in a newly created fork owned by the user/workspace.
```

ثم اضغط **Create Hub**.

> إذا كانت واجهة حسابك تعرض حقلًا اسمه **“What are you trying to achieve?”** بدل Description، استخدم نفس النص أعلاه. لا تختصره إلى جملة عامة مثل “build a browser”. المطلوب أن يعرف الوكيل أن هذه عملية استئناف مشروع قائم، وليست مشروعًا جديدًا.

المسار الرسمي الحالي لإنشاء Hub هو: فتح Hub من الشريط الجانبي، ثم `+ New`، ثم إدخال الاسم واللون والوصف وإنشاء الـHub. citeturn310437search0

---

# 3) إعداد Custom Instructions للـHub

بعد دخول Hub:

**⋯ → Edit Hub** أو افتح إعدادات الـHub ثم **Custom Instructions** حسب الواجهة الظاهرة.

ضع هذه التعليمات كاملة، ولا تختصرها:

```text
You are the senior software engineer and release engineer responsible for continuing the existing WebLibre Android browser project.

NON-NEGOTIABLE REPOSITORY SAFETY:
- NEVER modify, push to, merge into, delete, force-push, or otherwise alter the reference repository:
  https://github.com/brasilia736211600-netizen/WebLibre
- The first repository operation must create or use a NEW FORK/COPY of that repository.
- ALL experiments, commits, branches, CI changes, tests, and feature work must happen only in the NEW FORK.
- Preserve full Git history. Do not rebuild from scratch.
- Never use main/master of the reference repository as a scratch branch.

PROJECT:
- WebLibre is an existing Flutter/Dart Android browser.
- The current codebase includes a local package: packages/flutter_mozilla_components/.
- Android Components version investigated: 152.0.4.
- Work must preserve existing architecture.

PRIMARY PRODUCT REQUIREMENTS:
1. Independent User-Agent per container.
2. Independent Proxy per container.
3. Per-container settings UI for both.
4. Persistence and restoration.
5. Runtime isolation: Container A must never silently change Container B.
6. Correct behavior before first navigation.
7. Final CI/test/build quality.

CURRENT UA STATUS:
- ContainerMetadata.userAgent exists.
- JSON persistence exists.
- copyWith/equality/normalization support exists.
- Generated serialization and targeted tests exist.
- This does NOT mean runtime UA is complete.

CORRECT UA ARCHITECTURE:
ContainerMetadata.userAgent
 -> tab/session creation
 -> create EngineSession
 -> set session-level userAgentString/override
 -> create tab state with prepared session
 -> AddTabAction
 -> LoadUrlAction

UA MUST be applied before first navigation.
Do NOT solve this with a global GeckoRuntime UA.
Do NOT apply UA only after navigation.

NATIVE INTEGRATION:
- Local GeckoTabsApiImpl is the critical tab/session integration point.
- Current conceptual flow is create tab state -> AddTabAction -> LoadUrlAction.
- Android Components supports creating a tab with a prepared EngineSession.
- Use the smallest local integration that preserves existing architecture.

PROXY:
- Proxy is per container, not global.
- Verify new sessions, multiple tabs, duplicates, and restored sessions.
- Verify changing Container A cannot alter Container B.

RESTORE FORENSICS:
- syncEvents() currently returns Future<void> with no request/generation token.
- Tab-list events have sequence numbers but no request provenance.
- Stale debounced events may already be queued.
- RPC and GeckoStateEvents use separate channels.
- Arrival-order heuristics are not mathematically reliable.
- The previously proposed _freshSnapshotPending approach is rejected as UNSOUND.
- If reliable request/event correlation is needed, add explicit provenance and regenerate Pigeon.

YAGNI / ENGINEERING RULE:
Implement the smallest architecture that satisfies the invariant. Do not add a new subsystem when an existing WebLibre/Android Components hook is sufficient.

VALIDATION ORDER:
1. Targeted Dart tests.
2. flutter analyze.
3. Targeted Kotlin/native checks.
4. Pigeon generation consistency.
5. Targeted integration/build.
6. Full APK build only after the above are stable.

A previous full debug APK run spent about 756 seconds and failed because the expected APK artifact could not be found. Do not repeat expensive full builds for every tiny change.

WORK LOOP:
inspect -> implement -> test -> inspect diff -> commit -> continue

Every status update must contain concrete evidence:
- current branch;
- current commit SHA;
- files changed;
- tests run;
- results;
- blockers;
- next concrete action.

Do not claim any feature is complete unless code AND tests demonstrate completion.
```

### لماذا نضع هذه التعليمات في Hub؟

لأن Custom Instructions تنطبق على مشاريع Hub كلها، وهذا يمنع إعادة إرسال نفس القيود في كل محادثة. Genspark نفسه يوصي باستخدام Custom Instructions للتركيز والقواعد غير القابلة للتفاوض. citeturn310437search0

---

# 4) ما الملفات التي ترفعها إلى Hub؟

## لا ترفع المستودع كاملًا إلى Hub

هذا أهم قرار لتوفير Credits.

لا ترفع:

- ZIP كامل للمشروع.
- كل ملفات Dart/Kotlin.
- `build/`.
- `.dart_tool/`.
- Gradle caches.
- ملفات APK.
- ملفات Rust build الناتجة.
- أي ملف كبير لا يحتاجه الوكيل لفهم الحالة.

Hub يسمح بحد 10MB للملف، وGenspark يقول صراحةً إن تقليل الملفات يساعد في خفض استهلاك Credits. citeturn310437search0

## ارفع فقط ملفات السياق الصغيرة

الأولوية:

1. `docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md`
2. `docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`
3. `docs/GENSPARK_WEBLIBRE_STEP_BY_STEP_LOW_CREDIT_RUNBOOK_AR.md`

هذه الملفات الثلاثة هي **ذاكرة المشروع**.

لا تحتاج إلى تنزيلها من GitHub إذا كانت موجودة عندك محليًا؛ يمكنك تنزيلها من المستودع ثم رفعها، أو في واجهة Genspark التي تدعم GitHub استخدم المستودع/الملف مباشرة عندما يكون ذلك متاحًا.

إذا كانت الملفات غير موجودة على هاتفك، افتح المستودع في GitHub، ادخل إلى `docs/`، افتح الملف ثم **Download raw**/تنزيل الملف، وبعدها ارفعه في Hub.

---

# 5) هل أرفع ملفات المشروع المتبقية يدويًا؟

لا، ليس في البداية.

الأفضل أن تعطي Genspark وصولًا إلى **NEW FORK** عبر GitHub connector/Repository attachment عندما تكون هذه الإمكانية ظاهرة في حسابك. Genspark يذكر أن GitHub من الموصلات المدعومة، وأن بعض واجهات Genspark تسمح بإرفاق GitHub repository مباشرة من زر `+`. citeturn469078search0turn469078search1

بهذا:

```text
Hub memory
  ├─ handoff docs
  ├─ continuation prompt
  └─ operating rules

GitHub NEW FORK
  └─ actual source code
```

ولا تحتاج إلى نسخ مئات الملفات إلى Hub.

---

# 6) أول Project داخل Hub

من صفحة Hub اختر بدء مشروع/محادثة جديدة.

إذا ظهر الاختيار:

**@Genspark Code**

استخدمه لأعمال البرمجة.

إذا لم يظهر أو لم يكن متاحًا:

استخدم **Super Agent**؛ وهو الوكيل الافتراضي داخل Hub ويمكنه تنفيذ مهام طويلة ومعقدة، وتشغيل الأدوات والبيئة البرمجية. citeturn310437search0turn469078search2

## اسم المشروع

استخدم مثلًا:

`WebLibre Fork Continuation — Container UA + Proxy`

---

# 7) أول Prompt لا تستهلك Credits بإطلاق كبير

لا ترسل مباشرة: “نفذ كل شيء”.

أول رسالة يجب أن تكون **رسالة اكتشاف منخفضة التكلفة**.

استخدم:

```text
FIRST MISSION — READ ONLY. DO NOT MODIFY ANY FILES YET.

1. Confirm that you are connected to the NEW FORK, NOT the reference repository.
2. Report the exact repository URL, branch, HEAD commit SHA, and working directory.
3. Read docs/WEBLIBRE_PROJECT_HANDOFF_2026-08-28.md completely.
4. Read docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md completely.
5. Inspect the repository tree and determine the real current paths for:
   - ContainerMetadata
   - AddTabParams
   - GeckoTabsApi
   - GeckoTabsApiImpl
   - tab/session creation
   - container settings UI
   - proxy configuration
   - restore/session state
6. Compare the feature branch/current work against its base.
7. Do NOT edit, commit, push, merge, or create a PR yet.
8. Return only a concise evidence report with:
   repository, branch, HEAD SHA, relevant files, current UA status, current Proxy status, exact immediate blocker, and recommended next patch.

Stop after this audit.
```

هذا يوفر Credits لأن الوكيل يقوم بقراءة وفهم الحالة مرة واحدة بدل أن يبدأ تعديلات خاطئة ثم يصححها.

---

# 8) بعد تقرير الفحص — اجعل الوكيل يبدأ Vertical Slice واحدًا

بعد أن تتأكد أن التقرير يقول إنه يعمل على الـNEW FORK، أرسل:

```text
Proceed with ONE focused vertical slice only: per-container User-Agent runtime integration.

Do not touch the reference repository.
Do not start a full APK build.
Do not modify unrelated features.

Implement in this order:
1. Add userAgent to the SOURCE Pigeon/tab-creation contract only if the current code inspection confirms it is required.
2. Run the official Pigeon generation command.
3. Propagate the assigned container's userAgent to tab/session creation.
4. In GeckoTabsApiImpl, create/prepare the EngineSession and apply the container UA BEFORE first navigation.
5. Cover addTab first.
6. Add a targeted test.
7. Run targeted tests and flutter analyze.
8. Inspect the final diff for unrelated changes.
9. Commit the focused change.

Do not proceed to UI until the runtime slice passes.
Return evidence: branch, commit, changed files, tests, results, remaining issue.
```

---

# 9) لماذا لا نطلب منه المشروع كاملًا دفعة واحدة؟

لأن Super Agent يمكنه تنفيذ المهام الطويلة والعمل المتوازي، لكن كل خطوة غير صحيحة تستهلك Credits. Genspark نفسه ينصح بصياغة prompt محكمة أولًا في AI Chat ثم تسليمها إلى Super Agent حتى لا يستهلك الوكيل موارد في أسئلة/تصحيحات غير ضرورية. كما أن Super Agent الجديد مصمم للمهام الطويلة والبيئة التنفيذية الحقيقية. citeturn469078search2

استخدم قاعدة:

```text
Small verified slice
→ cheap validation
→ next slice
```

بدل:

```text
Huge prompt
→ hours of execution
→ wrong architecture
→ expensive repair
```

---

# 10) كيف تجعل العمل متوازيًا؟

بعد نجاح UA runtime slice، لا تطلب منه 10 أشياء في رسالة واحدة.

قسّمها إلى مسارات مستقلة:

### Track A — UA

- addTab
- addMultipleTabs
- duplicateTab
- restore
- A/B isolation test

### Track B — Proxy

- verify new-session application
- concurrent isolation
- restore
- regression tests

### Track C — UI

- container UA field
- container proxy controls
- reset/default behavior

### Track D — CI

- Pigeon consistency
- targeted tests
- APK artifact discovery

كل Track يبدأ فقط عندما تكون dependency السابقة واضحة. Genspark Hub يسمح بمشاريع متعددة داخل Hub وتشترك في السياق، لذلك لا تحتاج إلى تحميل الملفات مرة أخرى لكل مشروع. citeturn310437search0

---

# 11) ماذا تفعل عندما يطلب Genspark صلاحية GitHub؟

إذا طلب ربط GitHub:

1. اربطه بحساب GitHub الذي يملك الـNEW FORK.
2. لا تمنحه صلاحيات لا يحتاجها.
3. تأكد أن الوكيل يرى الـNEW FORK.
4. إذا كان بإمكانه القراءة لكنه لا يستطيع الكتابة، فهذا طبيعي؛ إمّا أعطه صلاحية الكتابة في الـNEW FORK أو نفّذ التغييرات يدويًا حسب ما تسمح به حسابك.
5. لا تستخدم صلاحية الكتابة لتجعل الوكيل يعمل على المرجع.

Genspark يذكر أن GitHub Connector من الموصلات المتاحة، وأن بعض Skills تتطلب الاتصال به قبل العمل. citeturn469078search0

---

# 12) ماذا تفعل إذا ظهر لك مربع “What are you trying to achieve?”

اكتب هذا بالضبط:

```text
Continue and complete the existing WebLibre Android browser project from its current engineering state. Preserve the existing architecture. Complete and harden independent per-container User-Agent and Proxy configuration, persistence, restoration, runtime isolation, per-container settings UI, tests, CI, and final APK validation. Do not rebuild from scratch. Do not modify the reference repository. First create or use a NEW FORK and perform all work only there. Read the project handoff documents inside the repository before changing anything. Work incrementally, verify each change with targeted tests, minimize unnecessary file reads and expensive builds, and keep Git history clean and reviewable.
```

### لماذا هذا النص طويل؟

لأنه يمثل **هدف المشروع** وليس أمر تنفيذ واحدًا. الـCustom Instructions تمثل القواعد الثابتة، بينما أول Prompt يمثل مهمة الفحص الأولى. الفصل بينهما يقلل تكرار النصوص في كل جلسة.

---

# 13) كيف تستخدم ملف الـContinuation Prompt؟

ملف:

`docs/GENSPARK_WEBLIBRE_FORK_CONTINUATION_PROMPT.md`

لا تحتاج إلى نسخه وإرساله في كل مرة.

أولًا اجعله موجودًا في Hub Files.

بعد ذلك قل للوكيل:

```text
Read and obey the repository continuation prompt and the master handoff document before continuing.
```

واستخدم Prompt جديدًا فقط للمهمة الحالية.

---

# 14) كيف تقلل Credits أكثر؟

## قاعدة 1 — لا ترفع ZIP المشروع

استخدم GitHub repository attachment/connector للشفرة عندما يكون متاحًا.

## قاعدة 2 — لا تطلب “analyze everything” في كل مرة

استخدم:

```text
Inspect only the files relevant to this task.
```

## قاعدة 3 — لا تشغّل APK بعد كل تعديل

الترتيب:

```text
unit test
→ analyze
→ targeted native test
→ integration/build
→ full APK
```

## قاعدة 4 — استخدم Hub بدل إعادة رفع الملفات

Hub يحفظ الملفات ويجعلها متاحة للمشاريع داخله. citeturn310437search0

## قاعدة 5 — اجعل الوكيل يثبت الـSHA قبل الكتابة

لا تسمح بتعديلات قبل:

```text
repository URL
branch
HEAD SHA
working directory
```

## قاعدة 6 — لا تجعله يفتح ملفات لا يحتاجها

مثال:

```text
For this task, inspect only:
- Pigeon contract
- tab repository/use case
- GeckoTabsApiImpl
- relevant tests
```

---

# 15) كيف تعرف أن الوكيل بدأ العمل على النسخة الصحيحة؟

قبل أي تعديل يجب أن يجيب:

```text
Repository: <NEW FORK URL>
Branch: <feature branch>
HEAD: <SHA>
Reference repository: NOT modified
```

إذا كتب رابط:

`brasilia736211600-netizen/WebLibre`

كمستودع الكتابة، أوقفه فورًا.

---

# 16) كيف تتعامل مع الأسئلة التي تحتاج موافقتك؟

أنت طلبت أن يستمر الوكيل في بقية العمل ولا يتوقف بسبب مهمة واحدة.

لذلك استخدم هذا المبدأ:

```text
If an action is blocked by a user-only permission, do not stop the project.
Record the blocker clearly, continue with all independent work that does not depend on that permission, and return to the blocked item later.
```

هذا مهم خصوصًا لـ:

- صلاحيات GitHub.
- Merge/PR approval.
- Secrets.
- Release signing.
- Android device access.

لا تجعل الوكيل يكرر السؤال عشر مرات.

---

# 17) كيف تطلب منه العمل الطويل؟

بعد نجاح الـVertical Slice الأول أرسل:

```text
Continue autonomously from the verified state.

Do not wait for another prompt between independent tasks.
Use the project roadmap and handoff document as the source of truth.
Work in small verified increments.
Parallelize independent investigation/work where the environment supports it, but never create conflicting writes to the same files or branch.
When one task is blocked, move to another independent task and return to the blocker later.
Do not run expensive APK builds until targeted validation is green.
At every milestone, record branch, SHA, changed files, tests, and blockers in the project handoff/status file.
```

---

# 18) كيف تجعل كل إنجاز محفوظًا داخل المشروع؟

اطلب من الوكيل بعد كل milestone:

```text
Update the project handoff/status document with the exact current state, commit SHA, completed work, remaining work, test evidence, blockers, and next actions. Do not delete previous history; append or update the status section carefully.
```

وهكذا لو انقطع الاتصال أو تغير الوكيل، يستطيع التالي القراءة والمتابعة.

---

# 19) متى تستخدم Skill في Genspark؟

لا تبدأ بـSkill مخصص من اليوم الأول.

ابدأ بالـHub + GitHub + Super Agent/Genspark Code.

بعد أن ينجح workflow مرة أو مرتين وتثبت طريقة العمل، يمكن تحويل workflow المتكرر إلى Skill؛ Genspark يوضح أن Skills مناسبة للعمليات المتكررة والقابلة للتوحيد، ويمكن تشغيلها من Super Agent. citeturn488003search2

مثال Skill مستقبلي:

`WebLibre Safe Engineering Loop`

ومهمته:

```text
Inspect → patch → targeted tests → diff audit → commit → update handoff
```

---

# 20) إذا كان Genspark يستخدم Super Agent على cloud

هذا مريح لكنه يستهلك Genspark credits أثناء عمل الوكيل السحابي. Genspark يوضح أن agents على cloud computer تستهلك credits، بينما agents على جهازك المحلي عبر GenTeam/Claude Code أو Codex CLI تستخدم عتادك ونماذجك ولا تستهلك Genspark credits بالطريقة نفسها. citeturn469078search3

لذلك:

### للأعمال السحابية السريعة

استخدم Super Agent/Genspark Code على NEW FORK.

### للأعمال البرمجية الطويلة جدًا

انظر إلى GenTeam + local agent إذا كان لديك Claude Code أو Codex CLI على جهاز آخر/بيئة مناسبة؛ Genspark يذكر أن local agents تعمل على جهازك وتستخدم وصول النموذج الخاص بك بدل credits السحابية. citeturn469078search3

---

# 21) ترتيب عملي كامل من البداية للنهاية

```text
STEP 01
GitHub
→ create NEW FORK
→ verify reference remains untouched

STEP 02
Genspark
→ Hub
→ + New
→ name
→ description / What are you trying to achieve?
→ Create Hub

STEP 03
Hub Custom Instructions
→ paste full safety/engineering rules

STEP 04
Hub Files
→ upload only the 3 small handoff docs
→ do NOT upload full repository ZIP

STEP 05
Genspark project
→ select Genspark Code if available
→ otherwise Super Agent

STEP 06
Connect GitHub
→ give access to NEW FORK
→ do not use reference as write target

STEP 07
READ-ONLY AUDIT PROMPT
→ repository
→ branch
→ SHA
→ actual paths
→ no changes yet

STEP 08
UA vertical slice
→ Pigeon source
→ generation
→ Dart propagation
→ Gecko session
→ pre-navigation UA
→ tests

STEP 09
UA follow-up
→ multiple tabs
→ duplicate
→ restore
→ A/B runtime isolation

STEP 10
Proxy hardening
→ new sessions
→ concurrent containers
→ restore
→ A/B isolation

STEP 11
Container UI
→ UA
→ Proxy
→ reset/default

STEP 12
Restore/forensic work
→ syncEvents provenance only if needed

STEP 13
CI
→ targeted gates
→ generation consistency
→ build verification

STEP 14
FULL APK
→ only after all targeted checks pass

STEP 15
FINAL HANDOFF
→ update project status
→ final commit SHA
→ tests
→ APK artifact
→ remaining risks
```

---

# 22) ما الذي لا تفعله

لا تفعل:

```text
❌ upload full WebLibre ZIP to Hub
❌ tell agent “rewrite the whole app”
❌ let agent write to reference repository
❌ run full APK for every tiny change
❌ blindly approve generated-code rewrites
❌ let agent invent file paths
❌ let agent call UA a global runtime setting
❌ accept arrival-order heuristics for syncEvents correlation
❌ merge the data-only PR and declare UA complete
```

افعل بدلًا من ذلك:

```text
✅ fork
✅ handoff docs
✅ GitHub connector
✅ read-only audit
✅ small vertical slices
✅ targeted tests
✅ clean commits
✅ explicit runtime isolation tests
✅ full build only at milestone
```

---

# 23) أول ثلاث رسائل داخل Genspark

### Message 1 — Audit

```text
Perform the read-only repository audit from the instructions above. Do not modify anything. Verify the NEW FORK, branch, HEAD SHA, handoff files, exact source paths, and current implementation status. Stop after the evidence report.
```

### Message 2 — First implementation

```text
Now implement only the per-container User-Agent runtime vertical slice. Keep the change minimal and architecture-preserving. Apply UA to EngineSession before first navigation. Run targeted tests and flutter analyze. Do not run the full APK build yet.
```

### Message 3 — Continue autonomously

```text
Continue autonomously from the verified state. Finish all independent UA work first, then harden per-container Proxy isolation, then implement the per-container settings UI, then restore correctness, tests, CI, and finally APK validation. Work incrementally, keep the Git history clean, and update the handoff/status document after each milestone. Never modify the reference repository.
```

---

# 24) نقطة التحقق بعد كل مهمة

قبل الانتقال للمهمة التالية يجب أن يعيد Genspark:

```text
Repository:
Branch:
HEAD SHA:
Changed files:
Tests:
Result:
Known blockers:
Next action:
```

إذا لم يقدم هذه البيانات، اطلب:

```text
Report the exact engineering checkpoint with repository, branch, HEAD SHA, changed files, tests, results, blockers, and next action. Do not perform unrelated work in this response.
```

---

# 25) ملاحظة عن واجهة Genspark الحالية

Genspark Hub حاليًا يدعم Projects متعددة داخل Hub، ويفيد في الاحتفاظ بالسياق والملفات بين المحادثات. Genspark يذكر أيضًا أن Super Agent هو الافتراضي في Hub، ويمكن استخدام `@` لاختيار Genspark Code أو Agents أخرى. citeturn310437search0

الواجهات قد تتغير قليلًا بين الويب والتطبيق، لذلك إذا اختلف اسم حقل عندك، استخدم المحتوى نفسه مع أقرب حقل دلالي: الاسم، الوصف، What are you trying to achieve، Custom Instructions، Files، ثم Project.

## النهاية التشغيلية

**لا تُدخل كامل source code يدويًا إلى Hub.**

التركيبة الصحيحة لتوفير Credits هي:

```text
Hub
= memory + handoff + rules

GitHub NEW FORK
= actual source code

Genspark Code / Super Agent
= execution

Targeted tests
= fast feedback

Full APK
= final milestone only
```

هذه البنية هي الأساس الذي ينبغي أن يبدأ منه أي وكيل لاحق.
