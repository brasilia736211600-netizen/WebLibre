# WebLibre — Runtime UA Restore Forensics

**Date:** 2026-08-31
**Branch:** `weblibre-ua-mainline-v3`
**Source inspection HEAD:** `5c7f81023792b51d9185f6c572f1f361bbbf9a01`
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

This is the path exercised by process-death restoration. It does **not** call the application's normal `GeckoTabsApiImpl.addTab(...)` path for each restored tab.

### 3. The restore representation does not carry the custom UA

`packages/flutter_mozilla_components/pigeons/gecko.dart` defines `RecoverableTab` with only:

- `engineSessionStateJson`
- `TabState state`

`TabState` carries `contextId`, URL, title, history state, etc., but no `userAgent` field.

`GeckoTabsApiImpl.mapTab(...)` maps the Pigeon `RecoverableTab` into Android Components' `mozilla.components.browser.state.state.recover.RecoverableTab` using the engine session state and tab state. No per-tab/container UA is injected there.

### 4. Existing Pigeon restore API is not the cold-start path

`GeckoTabService.restoreTabsByList(...)` and native `GeckoTabsApiImpl.restoreTabsByList(...)` exist for explicit Pigeon-driven restoration. They map recoverable tabs and call `tabsUseCases.restore(...)`.

The observed cold-start path in `GlobalComponents.restoreBrowserState(...)` restores directly from `core.sessionStorage`, so adding logic only to `GeckoTabsApiImpl.restoreTabsByList(...)` would not fix the tested process-death path.

### 5. Current repository/state drift discovered

The Master Project Map previously claimed dedicated native files named `ContainerUserAgentStore.kt` and `HistoryDelegateBindingMiddleware.kt` were present and source-verified. The actual current branch was checked directly and GitHub code search for `ContainerUserAgentStore` returns zero results. The exact claimed path is also absent.

Therefore those claims are documentation drift and must not be treated as implementation evidence. The actual current source of truth is the restore path described above.

## First causal boundary

The first proven causal boundary is:

`sessionStorage.restore -> RecoverableBrowserState -> tabsUseCases.restore`

where the restored session is created from persisted engine/session state without a persisted per-container UA being supplied to the restored `EngineSession` before its navigation.

This is sufficient to explain the observed fallback to Gecko/Firefox 152 and is stronger evidence than the previous source-only claim.

## YAGNI decision

Do **not** add:

- a second database,
- a global GeckoRuntime UA,
- arbitrary raw-UA spoofing,
- a new anti-detect architecture,
- a new Pigeon restore-generation mechanism,
- or a large fingerprint subsystem

as part of this fix.

The minimum-fix design must first reuse the existing `ContainerMetadata.userAgent` and existing `contextId`/container mapping, and must ensure that the UA is available to the restored EngineSession **before restored navigation**.

## Next execution boundary

1. Inspect the existing component/session-storage restore construction and identify the smallest hook that can associate restored `contextId` with the already-persisted container UA before the restored navigation starts.
2. Confirm whether the existing Flutter-side container metadata can be exposed to native at the required startup point without introducing a second persistence system.
3. Implement only that minimum correction if the call chain proves it is sufficient.
4. Add a focused regression test for restored-session UA application.
5. Run focused CI/native tests.
6. Produce one new integrated ARM64 validation APK and repeat Scenario 1.

Do not proceed to Scenarios 2–6 until Scenario 1 is revalidated.

## Evidence classification

- Runtime: `ANDROID-RUNTIME-VERIFIED` for the failure itself.
- Normal UA creation path: `SOURCE-VERIFIED`.
- Automatic restore path: `SOURCE-VERIFIED`.
- Restored UA correctness: `ANDROID-RUNTIME-VERIFIED = FAIL`.
- Current Master Map claims about the two dedicated native files: contradicted by actual repository inspection and must be reconciled.
