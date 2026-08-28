# WebLibre Master Handoff — 2026-08-28

## Purpose
Durable handoff for continuing WebLibre work in a future chat. GitHub is the source of truth; this file records project intent, current state, constraints, and next actions.

## Repository
- Fork: https://github.com/brasilia736211600-netizen/WebLibre
- Upstream: https://github.com/FaFre/WebLibre
- Default branch: `main`
- Primary P0 branch: `weblibre-p0-container-restore`
- APK unblock branch: `p0-apk-unblock`
- Open PR: #1 `fix(android): unblock AGP 9 APK build`

## Working model
- User has explicitly authorized direct GitHub work: inspect, create branches, edit files, commit, create/update PRs, run available CI actions, review results, and continue without repeatedly asking for permission.
- GitHub is the primary project-management channel in this chat.
- Do not claim background/asynchronous work after a response ends. When the user returns, re-read this handoff and the live GitHub state.
- Keep user involvement minimal. Ask only when a decision cannot be proven from repository evidence or when physical-device acceptance testing is required.

## Engineering policy
Use: AUDIT -> PLAN -> IMPLEMENT -> TEST -> VERIFY -> CHECKPOINT -> NEXT.

YAGNI / minimalism:
- Reuse existing capabilities before creating new abstractions.
- Prefer the smallest invariant-preserving patch.
- Do not add dependencies, broad refactors, parallel managers, or duplicate state without evidence.
- Speed means parallel independent work, not speculative commits.

Safety:
- Preserve existing user work.
- No destructive reset/clean/checkout operations.
- Never overwrite unrelated changes.
- No broad dependency upgrades during focused debugging.
- Do not expose credentials/secrets.
- Do not edit generated Pigeon/Drift sources directly.
- Do not change Drift schema or `TabDao.syncTabs()` body without proof.
- Keep container/session restoration separate from screenshot/black-screen investigation unless evidence proves a dependency.
- Destructive DB writes require authoritative/correlated evidence.

## Current stack
- Flutter 3.47.0
- Dart
- Melos 7.8.1
- Java 17
- Go 1.25.x
- Android NDK 29.0.14206865
- Kotlin / Gradle
- Gecko / Firefox Android Components 152.0.4
- Riverpod
- Drift
- GitHub Actions

## Core product goal
Stable WebLibre with deterministic tabs, containers, startup restore, private/isolation behavior, hierarchy, intents, proxy/routing, reliable screenshot/context-menu lifecycle, maintainable architecture, and the agreed container-scoped customization features.

## Agreed per-Container features
Each Container must have independent settings, configurable from that Container's own settings:
- User-Agent: independent per Container; not merely global app setting.
- Proxy: independent per Container; can be selected/configured per Container.
- These settings must not leak/collide between Containers.
- Container identity/session/storage/network/persona remain the organizing boundary.

Current proxy architecture evidence:
`ContainerMetadata` already contains `proxyConnectionId` and `bypassGlobalProxy`, with sanitization keyed to `contextualIdentity`. Treat Proxy as existing/partial/hardening work, not a blank feature.

User-Agent status: not yet proven implemented as a Container-scoped configurable feature. Do not assume it exists; audit native/Gecko capability and existing settings first.

## Current roadmap / task ledger
P0 data integrity:
- P0-DATA-001 Container/session restoration
- P0-DATA-002 Tab database/native synchronization
- P0-DATA-003 Tab identity/container persistence
- P0-DATA-004 Isolation-context integrity

P1 stability:
- P1-STABILITY-001 Screenshot/context-menu black screen
- P1-STABILITY-002 Startup lifecycle races
- P1-STABILITY-003 Background/foreground lifecycle

P2 navigation/restoration:
- P2-NAV-001 Selected-tab correctness
- P2-NAV-002 Selected-container correctness
- P2-NAV-003 Startup resume behavior
- P2-NAV-004 Intent startup behavior
- P2-NAV-005 Tab hierarchy restoration

P3 features:
- P3-FEATURE-001 Container assignment
- P3-FEATURE-002 App links
- P3-FEATURE-003 Proxy/routing integration
- P3-FEATURE-004 Search/history/extensions

P4 UX:
- P4-UX-001 Quick switcher
- P4-UX-002 Menus/gestures
- P4-UX-003 Startup UX

P5 architecture/performance:
- P5-ARCH-001 Performance
- P5-ARCH-002 Caching
- P5-ARCH-003 Modularization
- P5-ARCH-004 Offline/AI-assisted development improvements

Do not advance past an unresolved higher-priority data-integrity task unless the user explicitly changes priority.

## P0 facts already established
Problem observed:
- Container tabs can disappear after restart.
- Previous Container may not be restored.
- Ordinary/unassigned tabs may appear.
- Last page in previous Container may not reopen.

Unsafe design explicitly rejected:
`_freshSnapshotPending` / “first later tab-list event is the fresh snapshot”. Reason: stale debounced events, independent RPC/event channels, no provenance, no generation correlation. Never reintroduce without real correlation.

Preferred P0 mechanism implemented:
- Add authoritative native `getCurrentTabIds(): List<String>` via Pigeon.
- Native source: `components.core.store.state.tabs.map { it.id }`.
- Use authoritative RPC result at destructive reconciliation points.
- Conservative behavior on RPC failure: defer/no destructive write.

Critical files:
Flutter:
- `apps/weblibre/lib/features/geckoview/domain/providers/tab_list.dart`
- `apps/weblibre/lib/features/geckoview/domain/providers/selected_tab.dart`
- `apps/weblibre/lib/features/geckoview/domain/providers/restore_complete.dart`
- `apps/weblibre/lib/features/geckoview/domain/providers/tab_state.dart`
- `apps/weblibre/lib/features/geckoview/domain/repositories/tab.dart`
- `apps/weblibre/lib/features/geckoview/features/tabs/domain/providers/selected_container.dart`
- `apps/weblibre/lib/features/geckoview/features/tabs/data/database/daos/tab.dart`
- `apps/weblibre/lib/features/geckoview/features/tabs/data/database/definitions.drift`
- `apps/weblibre/lib/features/geckoview/features/browser/presentation/widgets/browser_home.dart`

Native:
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/api/GeckoTabsApiImpl.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/components/Events.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/FlutterEventMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/ext/EventSequence.kt`
- `packages/flutter_mozilla_components/lib/src/domain/services/gecko_event.dart`
- `packages/flutter_mozilla_components/lib/src/domain/services/gecko_tab.dart`
- `packages/flutter_mozilla_components/lib/src/extensions/subject.dart`

## P0 validation status
The validation workflow successfully reached:
- Pigeon bridge verification: PASS
- Flutter analyze: PASS for the observed run
- asset generation/update: PASS
- components build: PASS
- targeted TabRepository tests: PASS
- native source checkout: PASS
- gomobile combined runtime: PASS
- AAR verification: PASS

The prior failure was isolated to Debug APK compile.

A temporary diagnostic workflow was added on `p0-apk-unblock` to preserve the gomobile log as an artifact and to run validation on branch pushes.

## Android APK unblock
Open PR #1:
- Base: `weblibre-p0-container-restore`
- Head: `p0-apk-unblock`
- Title: `fix(android): unblock AGP 9 APK build`
- PR is intentionally Draft until CI proves the fix.

The branch contains an Android Gradle compatibility change intended to replace legacy `applicationVariants` / `com.android.build.OutputFile` usage with the modern `androidComponents` Variant API for release ABI version codes.

Important: the first implementation rewrote/cleaned unrelated formatting in `build.gradle`; this was recognized as violating minimal-diff discipline. Before merging, reduce the PR to the smallest necessary diff if technically possible and validate again.

## Proxy history / evidence
Known relevant commits include:
- `f248400f...` improve proxy routing
- `8204f2c6...` improve proxy routing and leak prevention
- `a99e0d90...` improve proxy UI, routing, isolation
- `11390410...` proxy autostart setting
- `a527b399...` sing-box random port to avoid collisions
- `9b4bc3c3...` improve custom DoH management
- `688860d0...` fix app-link reloading issue
- `54e277be...` improve app-link banner handling
- `4be71a09...` improve container menu and gestures
- `0a2c8b8a...` improve last tab selection
- `f3a2542b...` improve gesture logic
- `94f7bfe0...` new tab-bar gesture to open tab view
- `a59c77be...` background tab switching setting

These are existing functionality/history. Audit them rather than reimplementing.

## ContainerMetadata current evidence
`apps/weblibre/lib/features/geckoview/features/tabs/data/models/container_data.dart` currently has:
- `proxyConnectionId`
- `bypassGlobalProxy`
- `clearDataOnExit`
- `excludeFromIndex`
- `excludeFromHistory`
- `useCustomColor`
- `assignedSites`
- `strictMode`
- `isolatedAppLinkSettings`

`sanitized()` prevents proxy/bypass settings from persisting as effective routing when `contextualIdentity` is null.

## Restore/event model facts
- Cold start restore goes through `GlobalComponents.restoreBrowserState()`.
- Restore uses `RecoverableBrowserState` and dispatches restore completion.
- `selectedTabId` is intentionally null at start in the known path; previous selection is therefore a separate startup behavior concern.
- `Events.kt`: selected-tab debounce 50ms, restore-complete no debounce, tab-list debounce 25ms.
- `EventSequence` is process-global monotonic `AtomicLong`, but it does NOT make different streams one atomic transaction.
- `gecko_event.dart` filters each Subject by its own last sequence per identifier.
- `SubjectAddRecent` rejects older sequence numbers per subject/identifier.
- Therefore sequence ordering alone does not correlate an event to a specific RPC request.

## Screenshot/black-screen P1
Separate unresolved bug:
Long-press link -> context menu -> screenshot -> return to WebLibre -> black screen/freeze/unresponsive.

Investigate only after P0 is stable, using a separate reproduction matrix:
A long-press only
B long-press + screenshot
C context menu -> screenshot
D screenshot -> background/rotate -> resume
E screenshot with no context menu
Capture logcat, Flutter logs, Gecko/Android exceptions. Do not patch restore code speculatively.

## Required restore test matrix
A normal cold start
B one container
C multiple containers
D last selected tab inside container
E last selected unassigned tab
F multiple tabs/hierarchy
G empty container
H tombstone
I undo close
J isolated tab
K private tab
L share intent during startup
M killed-process restart
N background/foreground
O late/partial restore delivery
P temporary empty list
Q tab reordering
R container reassignment
Primary discriminators: L and O.

## Next actions when resuming
1. Re-read live GitHub state for `weblibre-p0-container-restore` and `p0-apk-unblock`.
2. Check PR #1 status and CI.
3. If APK fix CI is failing, inspect actual logs/artifacts and make the smallest correction.
4. Do not merge PR #1 until tests/build are genuinely green and the diff is minimal.
5. Close/clean temporary validation workflow artifacts when no longer needed, without deleting useful evidence.
6. Re-run/verify P0 destructive reconciliation paths and add targeted tests where the repository currently lacks them.
7. Once P0 is proven, proceed to P1 screenshot/context-menu lifecycle as a separate task.
8. Then perform Container Identity V1 audit.
9. Implement Container-scoped User-Agent using existing Gecko capability if available; otherwise add the smallest real API/config path.
10. Harden Container-scoped Proxy, ensuring independent per-container selection/configuration and no cross-container leakage.
11. Build a feature-gap matrix against this document and existing Git history before creating new P3 features.
12. Progress toward release only after source + targeted tests + lifecycle tests + physical-device acceptance where applicable.

## Human approval queue
Only items requiring human/product decision or physical device should be queued here. Do not let them block independent work.
- Physical device acceptance of Container restore matrix.
- Physical device reproduction/verification of screenshot black-screen bug.
- Any product decision where intended behavior cannot be inferred from code/history/specification.

## Source of truth priority
1. Live GitHub repository and current branch/commits.
2. This handoff file and the master protocol files in the conversation/library.
3. Older memory/context, only when not contradicted by live GitHub or newer protocol evidence.
