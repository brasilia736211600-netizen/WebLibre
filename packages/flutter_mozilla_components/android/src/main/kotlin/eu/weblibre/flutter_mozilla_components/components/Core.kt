/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import android.content.SharedPreferences
import android.os.Environment
import androidx.core.content.ContextCompat
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.ColorSchemePreference
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.interceptor.AppRequestInterceptor
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import eu.weblibre.flutter_mozilla_components.EngineProvider
import eu.weblibre.flutter_mozilla_components.EngineProvider.getOrCreateRuntime
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.history.FallbackHistoryDelegate
import eu.weblibre.flutter_mozilla_components.middleware.HistoryDelegateBindingMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.ContainerUserAgentCreateSessionMiddleware
import eu.weblibre.flutter_mozilla_components.PermissionStorage
import eu.weblibre.flutter_mozilla_components.services.MediaSessionService
import eu.weblibre.flutter_mozilla_components.activities.NotificationActivity
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStores
import eu.weblibre.flutter_mozilla_components.middleware.AppLinkNavigationMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.FlutterEventMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.HistoryMetadataMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.HistoryMetadataService
import eu.weblibre.flutter_mozilla_components.middleware.SandboxCaptureMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.SaveToPDFMiddleware
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.push.WebNotificationDrainCoordinator
import kotlinx.coroutines.FlowPreview
import mozilla.components.browser.engine.gecko.permission.GeckoSitePermissionsStorage
import mozilla.components.browser.engine.gecko.util.EngineDownloadDelegate
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.session.storage.SessionStorage
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.engine.middleware.SessionPrioritizationMiddleware
import mozilla.components.browser.state.engine.middleware.TranslationsMiddleware
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.storage.sync.PlacesBookmarksStorage
import mozilla.components.browser.storage.sync.PlacesHistoryStorage
import mozilla.components.browser.storage.sync.RemoteTabsStorage
import mozilla.components.browser.thumbnails.ThumbnailsMiddleware
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy
import mozilla.components.concept.engine.fission.WebContentIsolationStrategy
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.addons.AddonManager
import mozilla.components.feature.addons.amo.AMOAddonsProvider
import mozilla.components.feature.addons.migration.DefaultSupportedAddonsChecker
import mozilla.components.feature.addons.update.DefaultAddonUpdater
import mozilla.components.feature.customtabs.store.CustomTabsServiceStore
import mozilla.components.feature.pwa.ManifestStorage
import mozilla.components.feature.pwa.WebAppShortcutManager
import mozilla.components.feature.downloads.DownloadMiddleware
import mozilla.components.feature.media.MediaSessionFeature
import mozilla.components.feature.media.middleware.LastMediaAccessMiddleware
import mozilla.components.feature.media.middleware.RecordingDevicesMiddleware
import mozilla.components.feature.prompts.PromptMiddleware
import mozilla.components.feature.prompts.file.FileUploadsDirCleaner
import mozilla.components.feature.prompts.file.FileUploadsDirCleanerMiddleware
import mozilla.components.feature.readerview.ReaderViewMiddleware
import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.feature.session.HistoryDelegate
import mozilla.components.feature.session.middleware.LastAccessMiddleware
import mozilla.components.feature.session.middleware.undo.UndoMiddleware
import mozilla.components.feature.sitepermissions.OnDiskSitePermissionsStorage
import mozilla.components.feature.webnotifications.WebNotificationFeature
import mozilla.components.concept.base.crash.Breadcrumb
import mozilla.components.concept.base.crash.CrashReporting
import mozilla.components.support.base.worker.Frequency
import org.mozilla.geckoview.GeckoRuntime
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.Job
import mozilla.components.support.utils.DefaultDownloadFileUtils
import java.util.concurrent.TimeUnit

private const val AMO_COLLECTION_MAX_CACHE_AGE = 24 * 60L

class Core(
    private val context: Context,
    private val components: Components,
    private val flutterEvents: GeckoStateEvents,
    private val extensionEvents: BrowserExtensionEvents
) {
    private val noOpCrashReporter = object : CrashReporting {
        override fun submitCaughtException(throwable: Throwable): Job = Job()

        override fun recordCrashBreadcrumb(breadcrumb: Breadcrumb) = Unit
    }

    val prefs by lazy {
        PreferenceManager.getDefaultSharedPreferences(context)
    }

    val engineSettings by lazy {
        DefaultSettings(
            requestInterceptor = requestInterceptor,
            historyTrackingDelegate = FallbackHistoryDelegate(historyStorageDelegate),
            testingModeEnabled = false,
            remoteDebuggingEnabled = false,
            automaticFontSizeAdjustment = true,
            fontInflationEnabled = true,
            suspendMediaWhenInactive = false,
            getDesktopMode = {
                store.state.desktopMode
            },
            enterpriseRootsEnabled = false,
            emailTrackerBlockingPrivateBrowsing = true,
            trackingProtectionPolicy = createTrackingProtectionPolicy(TrackingProtectionPolicy.strict()),
            httpsOnlyMode = Engine.HttpsOnlyMode.ENABLED,
            globalPrivacyControlEnabled = true,
            preferredColorScheme = ColorSchemePreference.read(prefs),
            cookieBannerHandlingMode = EngineSession.CookieBannerHandlingMode.REJECT_ALL,
            cookieBannerHandlingModePrivateBrowsing = EngineSession.CookieBannerHandlingMode.REJECT_ALL,
            cookieBannerHandlingGlobalRules = true,
            cookieBannerHandlingGlobalRulesSubFrames = true,
            webContentIsolationStrategy = WebContentIsolationStrategy.ISOLATE_HIGH_VALUE,
            downloadDelegate = EngineDownloadFileUtils(
                context = context,
                downloadLocation = {
                    Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_DOWNLOADS,
                    ).path
                },
            ),
            useContentBlockingDatabase =
                GlobalComponents.startupSettings?.useContentBlockingDatabase ?: true
        )
    }

    val runtime: GeckoRuntime by lazy {
        getOrCreateRuntime(context)
    }

    val engine: Engine by lazy {
        EngineProvider.createEngine(context, engineSettings, extensionEvents, flutterEvents)
    }

    val client: Client by lazy {
        EngineProvider.createClient(context)
    }

    val thumbnailStorage by lazy { ThumbnailStorage(context) }
    val icons by lazy { BrowserIcons(context, client) }

    val geckoSitePermissionsStorage by lazy {
        val geckoRuntime = EngineProvider.getOrCreateRuntime(context)
        GeckoSitePermissionsStorage(geckoRuntime, OnDiskSitePermissionsStorage(context))
    }

    val addonManager by lazy {
        AddonManager(store, engine, addonsProvider, addonUpdater)
    }

    val addonUpdater by lazy {
        DefaultAddonUpdater(
            context,
            Frequency(12, TimeUnit.HOURS),
            components.notificationsDelegate
        )
    }

    val addonsProvider by lazy {
        if (components.addonCollection != null)
            AMOAddonsProvider(
                context,
                client,
                serverURL = components.addonCollection.serverURL,
                collectionUser = components.addonCollection.collectionUser,
                collectionName = components.addonCollection.collectionName,
                maxCacheAgeInMinutes = AMO_COLLECTION_MAX_CACHE_AGE
            ) else
            AMOAddonsProvider(
                context,
                client,
                maxCacheAgeInMinutes = AMO_COLLECTION_MAX_CACHE_AGE
            )
    }

    val supportedAddonsChecker by lazy {
        DefaultSupportedAddonsChecker(
            context,
            Frequency(12, TimeUnit.HOURS)
        )
    }

    val fileUploadsDirCleaner: FileUploadsDirCleaner by lazy {
        FileUploadsDirCleaner { context.cacheDir }
    }

    val historyMetadataService by lazy {
        HistoryMetadataService(storage = historyStorage)
    }

    val webNotificationDrainCoordinator = WebNotificationDrainCoordinator()

    @OptIn(FlowPreview::class)
    val store by lazy {
        BrowserStore(
            middleware = listOf(
                SandboxCaptureMiddleware,
                AppLinkNavigationMiddleware(
                    PendingAppLinkStores.forProfile(
                        components.profileApplicationContext.relativePath,
                    ),
                ),
                HistoryMetadataMiddleware(historyMetadataService),
                ContainerUserAgentCreateSessionMiddleware(
                    engine = engine,
                    profileContext = components.profileApplicationContext,
                    scope = MainScope(),
                ),
                HistoryDelegateBindingMiddleware(
                    profileContext = components.profileApplicationContext,
                    storageDelegate = historyStorageDelegate,
                ),
                FlutterEventMiddleware(flutterEvents),
                DownloadMiddleware(
                    applicationContext = context,
                    downloadServiceClass = DownloadService::class.java,
                    deleteFileFromStorage = { false },
                    downloadFileUtils = DefaultDownloadFileUtils(
                        context = context,
                        downloadLocation = {
                            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path
                        },
                    ),
                ),
                ThumbnailsMiddleware(thumbnailStorage),
                ReaderViewMiddleware(),
                UndoMiddleware(),
                LastAccessMiddleware(),
                SessionPrioritizationMiddleware(),
                RecordingDevicesMiddleware(context, components.notificationsDelegate),
                PromptMiddleware(),
                SaveToPDFMiddleware(),
                FileUploadsDirCleanerMiddleware(fileUploadsDirCleaner),
                LastMediaAccessMiddleware(),
                TranslationsMiddleware(
                    engine,
                    MainScope(),
                    false,
                    isTranslationsEnabled = { true }),
            ) + EngineMiddleware.create(
                engine,
                trimMemoryAutomatically = false,
            )
        ).apply {
            components.events.registerFlowEvents(this)

            icons.install(engine, this)

            val webNotificationFeature = WebNotificationFeature(
                context,
                engine,
                icons,
                R.drawable.ic_launcher_foreground,
                geckoSitePermissionsStorage,
                NotificationActivity::class.java,
                notificationsDelegate = components.notificationsDelegate,
            )
            webNotificationDrainCoordinator.delegate = webNotificationFeature
            engine.registerWebNotificationDelegate(webNotificationDrainCoordinator)

            MediaSessionFeature(context, MediaSessionService::class.java, this).start()
        }
    }

    val customTabsStore by lazy { CustomTabsServiceStore() }
    val webAppManifestStorage by lazy { ManifestStorage(context) }

    val webAppShortcutManager by lazy {
        WebAppShortcutManager(context, client, webAppManifestStorage)
    }

    val sessionStorage: SessionStorage by lazy {
        SessionStorage(context, engine)
    }

    val lazyHistoryStorage = lazy { PlacesHistoryStorage(context) }

    val historyStorageDelegate: HistoryTrackingDelegate by lazy {
        HistoryDelegate(lazyHistoryStorage)
    }

    val lazyBookmarksStorage = lazy { PlacesBookmarksStorage(context) }
    val lazyRemoteTabsStorage = lazy { RemoteTabsStorage(context, noOpCrashReporter) }

    val historyStorage by lazy { lazyHistoryStorage.value }
    val bookmarksStorage by lazy { lazyBookmarksStorage.value }
    val remoteTabsStorage by lazy { lazyRemoteTabsStorage.value }

    val permissionStorage by lazy { PermissionStorage(geckoSitePermissionsStorage) }

    val requestInterceptor = AppRequestInterceptor(context)

    private fun createTrackingProtectionPolicy(
        trackingPolicy: EngineSession.TrackingProtectionPolicyForSessionTypes,
        normalMode: Boolean = true,
        privateMode: Boolean = true,
    ): TrackingProtectionPolicy {
        return when {
            normalMode && privateMode -> trackingPolicy
            normalMode && !privateMode -> trackingPolicy.forRegularSessionsOnly()
            !normalMode && privateMode -> trackingPolicy.forPrivateSessionsOnly()
            else -> TrackingProtectionPolicy.none()
        }
    }

}