# WebLibre — Privacy / Data-Flow Audit

**Date:** 2026-08-31  
**Branch:** `weblibre-ua-mainline-v3`  
**Purpose:** Durable record of the privacy review requested for the personal WebLibre build.

## Non-negotiable product rule

The app must not silently collect, identify, profile, or transmit user/device data to the former upstream developer or to any third-party service merely because the app is installed or running.

User-directed network traffic is different: when the user opens a website, searches, loads a feed, uses a proxy/Tor service, signs in, or explicitly enables an online feature, the corresponding network request is part of that requested feature. Such traffic must still be minimized and clearly scoped.

Required policy for future work:

`NO SILENT TELEMETRY -> NO SILENT DEVICE IDENTIFIERS -> NO SILENT BACKGROUND USER-DATA UPLOAD -> EXPLICIT OPT-IN FOR OPTIONAL ONLINE SERVICES`

## Confirmed findings from source inspection

### 1. Upstream identity is still present in source/legal metadata

The source files retain upstream copyright headers. These must **not** be blindly deleted: the repository is AGPL-licensed and required copyright/license notices must remain where legally required.

The user-facing About dialog no longer promotes the upstream developer through feedback, donation, documentation, or upstream GitHub links. The visible product identity is `WebLibre Personal Edition • Maintained by Braziao`.

The personal product identity must not falsely claim original authorship of inherited code. Upstream legal notices remain where required.

### 2. Background feed fetching is an automatic outbound-data path

`apps/weblibre/lib/main.dart` imports `background_fetch` and configures a release-mode background task with `minimumFetchInterval: 15`, `stopOnTerminate: false`, `startOnBoot: true`, and network type `ANY`. The task calls `FetchArticlesController.fetchAllArticles()`, which reads locally configured feed URLs and requests them.

This is not required for normal browsing and is not a user-initiated request at the time it executes. It remains a confirmed privacy/battery hardening target.

**Status:** PENDING. The current code has not yet been changed because the background registration lives in the large application bootstrap file. Do not mark this item complete until the exact startup path is removed/disabled and CI verifies it.

### 3. Account callback / handoff path is now disabled

The previous startup callback listener parsed `weblibre://account/callback` handoff codes and forwarded them to the account authentication repository. That was an inherited account data path and was not appropriate to leave active in the personal build without explicit product opt-in.

**Status:** SOURCE-CHANGED. `account_callback_handler.dart` now keeps the existing Riverpod provider only as a compatibility boundary for startup wiring and performs no account authentication, handoff redemption, synchronization, or network operation.

### 4. Supabase account dependency removed from the application package

The application `pubspec.yaml` previously declared `supabase: ^2.16.1` for the inherited account/auth/sync stack.

**Status:** SOURCE-CHANGED. The direct Supabase dependency has been removed from the application package. The remaining legacy account source tree must not be treated as runtime-active merely because source files still exist; the focused CI build is the required next proof that no reachable dependency remains.

### 5. Account sign-in no longer sends device name

`AccountAuthRepository.startSignIn()` previously added `device_name` from Android device information to the account handoff query.

**Status:** SOURCE-CHANGED. The handoff no longer includes the Android device name.

### 6. Account sync no longer persists source device identifier

`AccountSyncRepository.storeDocument()` previously accepted and persisted `sourceDeviceId` in the `account_sync_documents` row.

**Status:** SOURCE-CHANGED. The repository now deliberately writes `source_device_id: null` even if a legacy caller supplies a value. This is defense-in-depth against reintroducing device identifiers into sync metadata.

Existing server-side records are not assumed to be deleted by a client-side code change. Deletion of already-uploaded data requires an explicit account/data-management action.

### 7. Account and Firefox Sync are removed from the personal Settings UI

The personal Settings screen no longer exposes `WebLibre Account` or `Firefox Sync` as user-facing service categories.

**Status:** SOURCE-CHANGED. The visible product surface is removed; the remaining legacy source tree is pending dead-source/dependency cleanup after focused CI verification.

### 8. Android permissions need capability-by-capability review

The manifest requests network, camera, microphone, location, storage/media, notifications, credential-manager, and package-visibility capabilities, among others.

These permissions are not automatically evidence of data exfiltration. Browser functions such as websites requesting camera/microphone/location and user-initiated file/media handling can legitimately require them. `QUERY_ALL_PACKAGES` and persistent/background services deserve separate minimization review.

No permission is to be removed blindly; each must be mapped to a concrete feature and then tested after removal.

### 9. `usesCleartextTraffic="true"` is a security-hardening candidate

The Android manifest currently allows cleartext traffic. This is not itself proof that user data is being transmitted in cleartext, especially because Gecko has its own networking stack, but it weakens the platform-level default. It should be investigated separately and changed only after confirming compatibility with required browser/proxy functionality.

## Explicitly out of scope for deletion

Do **not** classify the following as silent telemetry merely because they send data over the network:
- normal web navigation initiated by the user;
- user-entered searches sent to the selected search provider;
- user-selected proxy/Tor traffic;
- user-initiated RSS/feed refreshes;
- explicit sharing/export operations.

The privacy goal is to prevent **unrequested app-level collection/transmission**, not to disable the fundamental purpose of a web browser.

## Upstream attribution rule

The personal product identity may replace upstream branding in the user-facing UI, About screen, package/app metadata, and promotional links where legally permissible.

However, AGPL/license/copyright notices that must be retained remain in source and legal documentation. The project must not falsely claim original authorship of upstream code.

## Immediate execution queue

1. Remove automatic `background_fetch` article refresh from release startup; retain manual feed refresh. **PENDING**
2. Disable inherited account callback/handoff data path. **DONE — source changed**
3. Remove direct Supabase application dependency used by the inherited account stack. **DONE — source changed; CI pending**
4. Remove `device_name` from account sign-in handoff. **DONE — source changed**
5. Stop sending Android device name as sync-document `sourceDeviceId`. **DONE — source changed**
6. Remove account and Firefox Sync from the personal Settings UI. **DONE — source changed**
7. Audit push/unified-push registration and all background services for silent identifiers/network traffic.
8. Audit `QUERY_ALL_PACKAGES`, location, camera, microphone, media, and cleartext-network capability against concrete feature use.
9. Search all application code for outbound HTTP/WebSocket/search/feed endpoints and classify each as user-initiated, explicitly opted-in, required for an enabled feature, or silent.
10. Remove dead account/sync source files after CI proves no reachable dependency remains.
11. Add a local privacy/data-flow screen that accurately states what is sent, when, and under what user action; do not claim zero network traffic because WebLibre is a browser.
12. Measure APK/runtime cost before removing unrelated features for size/performance reasons.

## Evidence rule

Every privacy change follows:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

No feature is deleted merely because a dependency name looks suspicious. No upstream legal notice is deleted merely because the user-facing identity is being changed.
