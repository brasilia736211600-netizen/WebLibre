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

The user-facing About dialog, however, previously promoted the upstream developer through:
- upstream copyright/legalese;
- feedback URL;
- donation URL;
- documentation URL;
- upstream GitHub URL.

The About dialog has now been changed to the personal-build identity and no longer contains those upstream promotional links. Legal source notices remain intact.

### 2. Background feed fetching is an automatic outbound-data path

`apps/weblibre/lib/main.dart` imports `background_fetch` and configures a release-mode background task with:
- `minimumFetchInterval: 15`;
- `stopOnTerminate: false`;
- `startOnBoot: true`;
- network type `ANY`.

The task calls `FetchArticlesController.fetchAllArticles()`, which reads all locally configured feed URLs and requests them through the feed reader.

This is not required for normal browsing and is not a user-initiated request at the time it executes. It is therefore a privacy/battery hardening target and should be removed or changed to an explicit user-controlled refresh setting. The default personal build must not silently fetch user-configured feeds in the background.

**Status:** identified; implementation removal pending because `main.dart` is a large generated/application file and must be changed and tested as a complete source update.

### 3. Account service is an explicit online feature, but it currently sends a device identifier during sign-in

`AccountAuthRepository.startSignIn()` builds the account URL with:
- `mode=handoff`;
- PKCE challenge;
- `app_version`;
- `device_name`.

The account client then maintains an authenticated session and can access account/subscription/search-credit/sync services.

The account feature is user-initiated by sign-in and is therefore not equivalent to hidden telemetry. However, `device_name` is unnecessary device-identifying metadata for the core sign-in handoff and should not be transmitted by default.

**Target:** remove `device_name` from the sign-in handoff and stop passing `sourceDeviceId` into sync-document metadata. Preserve explicit account functionality unless a later product decision removes the whole account service.

### 4. Encrypted sync is opt-in but still transmits metadata

The account sync repository requires a signed-in account and stores encrypted content blobs, but its rows also contain metadata including:
- source device ID;
- source app version;
- labels and timestamps.

The current UI passes the Android device name as `sourceDeviceId`.

The personal build should stop sending the device name as sync metadata. Existing server-side records are not assumed to be deleted by a client-side code change; deletion of already-uploaded data requires an explicit account/data-management action.

### 5. Supabase is an account backend, not evidence of anonymous telemetry by itself

`pubspec.yaml` contains the `supabase` dependency. `account_auth.dart` uses it for account authentication/session management and `account_sync_repository.dart` uses it for explicitly signed-in sync documents.

The presence of the dependency alone is not sufficient evidence of background telemetry. Do not delete it solely because it exists; trace actual call sites and user gating before changing account architecture.

### 6. Android permissions need capability-by-capability review

The manifest requests network, camera, microphone, location, storage/media, notifications, credential-manager, and package-visibility capabilities, among others.

These permissions are not automatically evidence of data exfiltration. Browser functions such as websites requesting camera/microphone/location and user-initiated file/media handling can legitimately require them. `QUERY_ALL_PACKAGES` and persistent/background services deserve separate minimization review because they are broader than ordinary page browsing.

No permission is to be removed blindly; each must be mapped to a concrete feature and then tested after removal.

### 7. `usesCleartextTraffic="true"` is a security-hardening candidate

The Android manifest currently allows cleartext traffic. This is not itself proof that user data is being transmitted in cleartext, especially because Gecko has its own networking stack, but it weakens the platform-level default. It should be investigated separately and changed only after confirming compatibility with required browser/proxy functionality.

## Explicitly out of scope for deletion

Do **not** classify the following as silent telemetry merely because they send data over the network:
- normal web navigation initiated by the user;
- user-entered searches sent to the selected search provider;
- user-selected proxy/Tor traffic;
- user-initiated RSS/feed refreshes;
- explicit account sign-in and account operations;
- explicit sharing/export operations.

The privacy goal is to prevent **unrequested app-level collection/transmission**, not to disable the fundamental purpose of a web browser.

## Upstream attribution rule

The personal product identity may replace upstream branding in the user-facing UI, About screen, package/app metadata, and promotional links where legally permissible.

However, AGPL/license/copyright notices that must be retained remain in source and legal documentation. The project must not falsely claim original authorship of upstream code.

## Immediate execution queue

1. Remove automatic `background_fetch` article refresh from release startup; retain manual feed refresh.
2. Remove `device_name` from account sign-in handoff.
3. Stop sending Android device name as sync-document `sourceDeviceId`.
4. Audit push/unified-push registration and all background services for silent identifiers/network traffic.
5. Audit `QUERY_ALL_PACKAGES`, location, camera, microphone, media, and cleartext-network capability against concrete feature use.
6. Search all application code for outbound HTTP/WebSocket/Supabase/search/feed endpoints and classify each as user-initiated, explicitly opted-in, or silent.
7. Add a local privacy/data-flow screen that accurately states what is sent, when, and under what user action; do not claim zero network traffic because WebLibre is a browser.
8. Measure APK/runtime cost before removing unrelated features for size/performance reasons.

## Evidence rule

Every privacy change follows:

`READ -> VERIFY -> RECONCILE -> PLAN -> EXECUTE -> TEST -> DIFF -> COMMIT -> SAVE STATE`

No feature is deleted merely because a dependency name looks suspicious. No upstream legal notice is deleted merely because the user-facing identity is being changed.
