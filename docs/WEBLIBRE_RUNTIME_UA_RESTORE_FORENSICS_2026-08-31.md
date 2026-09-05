# WebLibre — Runtime UA Restore Forensics

**Date:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Source inspection checkpoint:** `5c7f81023792b51d9185f6c572f1f361bbbf9a01`
**Runtime-tested APK source:** `3aa06cf6ee090e42c9b7bff6abbf17f737b1fef5`
**Runtime result:** Scenario 1 FAIL

## Runtime evidence

Before process death, Container A sent the configured UA:

`Mozilla/5.0 (Linux; Android 14; SM-S928B/DS) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36`

After process death/relaunch, Container A and its tab were restored, but the request-observed UA became:

`Mozilla/5.0 (Android 12; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0`

This proves that tab/container restoration and per-container UA restoration are separate runtime properties. The first is working; the second is not.

## Source verification

### 1. Normal tab creation already applies the container UA

`apps/weblibre/lib/features/geckoview/domain/repositories/tab.dart` passes `assignedContainer?.metadata.userAgent` into `GeckoTabService.addTab(...)`.

The native `GeckoTabsApiImpl.addTab(...)` creates an `EngineSession` and sets `session.settings.userAgentString = userAgent` before dispatching the new tab. The same pattern exists for duplicate tabs and multi-add.

Therefore the normal/pre-navigation path is not the observed failure.

### 2. The automatic cold-start restore path is different

`packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/GlobalComponents.kt` contains `restoreBrowserState(...)`.

For the first full setup it calls:

- `newComponents.core.sessionStorage.restore { true }`
- `newComponents.useCases.tabsUseCases.restore(RecoverableBrowserState(...))`
- then dispatches `RestoreCompleteAction`.

This path does not call the application's normal `GeckoTabsApiImpl.addTab(...)` path for each restored tab.

### 3. The repository already contains a restore-binding implementation

Actual files on the current branch are:

- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/middleware/HistoryDelegateBindingMiddleware.kt`
- `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/feature/ContainerUserAgentStore.kt`

`Core.kt` installs `HistoryDelegateBindingMiddleware` before `EngineMiddleware`.

On `EngineAction.LinkEngineSessionAction`, the middleware obtains the restored tab's `contextId`, reads the existing per-profile `tab.db` through `ContainerUserAgentStore`, and if a UA is found sets:

`engineSession.settings.userAgentString = userAgent`

The implementation was introduced by:

- `435c1e8bad653213bfb44e63235ac86741f88db` — `fix(restore): bind persisted container UA during session linking`
- `64e196c6213abddde0a4446b1fc876bb142a6edf` — `fix(restore): pass actual profile context to UA lookup`

Therefore the current problem is **not** simply “the restore path has no UA binding.” A source-level binding exists, and it already uses the existing `tab.db` rather than a second persistence system.

### 4. The Pigeon RecoverableTab limitation is not currently the first fix target

`packages/flutter_mozilla_components/pigeons/gecko.dart` defines `RecoverableTab` with `engineSessionStateJson` plus `TabState`, and `TabState` contains `contextId` but no `userAgent`.

However, the existing `HistoryDelegateBindingMiddleware` was explicitly designed to recover the UA after Android Components creates/links the EngineSession, using the existing `contextId` and `tab.db`. Therefore adding `RecoverableTab.userAgent` or forking Android Components is **not justified yet**.

### 5. ContainerUserAgentStore is tested only at parsing level

`ContainerUserAgentStoreTest.kt` currently verifies matching context, different-context rejection, blank-UA handling, and malformed metadata handling.

There is no focused test proving that the real profile `tab.db` can be opened/read during the actual cold-start restore timing, nor a runtime trace proving that `LinkEngineSessionAction` reaches the middleware with the expected `contextId` and that `ContainerUserAgentStore.get(...)` returns the expected UA.

### 6. Strongest current hypothesis boundary

The runtime contradiction is now narrower:

`restored session exists -> HistoryDelegateBindingMiddleware should bind UA -> observed navigation still used default UA`

At least one of these must be false at runtime:

1. the restore-created session reaches `HistoryDelegateBindingMiddleware` through `LinkEngineSessionAction` before the first navigation;
2. the middleware sees the expected `contextId`;
3. `ContainerUserAgentStore.get(profileContext, contextId)` can read `tab.db` at that exact startup point;
4. `engineSession.settings.userAgentString = userAgent` is applied early enough to affect the restored navigation;
5. the observed request belongs to the same restored EngineSession whose settings were modified.

The source alone does not distinguish these possibilities. The Android runtime failure proves the current implementation is insufficient in practice, but **does not yet justify a new architecture**.

## YAGNI decision

Do **not** add yet:

- a second database,
- a global GeckoRuntime UA,
- arbitrary raw-UA spoofing,
- a new anti-detect architecture,
- `RecoverableTab.userAgent`,
- an Android Components fork,
- or a new Pigeon restore contract.

The next change should be a focused diagnostic/regression instrument around the existing restore-binding path. Only if that evidence proves the current hook cannot affect the first restored navigation should we move to the next-minimum mechanism.

## Next execution boundary

1. Add a focused, low-noise diagnostic/test boundary around `HistoryDelegateBindingMiddleware` and `ContainerUserAgentStore.get(...)` that can distinguish `contextId missing` vs `DB lookup failure` vs `UA assignment too late/not effective`.
2. Add a real SQLite-backed test for `ContainerUserAgentStore.get(...)` using a profile-style `tab.db` containing the same `container.metadata` shape used by Drift.
3. If the source test proves lookup works, instrument the middleware path only for the validation build so the next single Android run can identify whether the hook executes and what `contextId`/UA it sees.
4. Implement the minimum correction indicated by that evidence.
5. Run focused CI/native tests.
6. Produce one new integrated ARM64 validation APK only after focused checks are green, then repeat Scenario 1.

Do not proceed to Scenarios 2–6 until Scenario 1 is revalidated.

## Evidence classification

- Runtime: `ANDROID-RUNTIME-VERIFIED` for the failure itself.
- Normal UA creation path: `SOURCE-VERIFIED`.
- Automatic restore path: `SOURCE-VERIFIED`.
- Existing restore UA middleware/store: `SOURCE-VERIFIED`.
- Restored UA correctness: `ANDROID-RUNTIME-VERIFIED = FAIL`.
- Exact first runtime failure point inside the existing restore binding: **NOT YET PROVEN**.
