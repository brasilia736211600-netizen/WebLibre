/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import android.os.SystemClock
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.ContainerUserAgentStore
import eu.weblibre.flutter_mozilla_components.history.HistoryExclusions
import eu.weblibre.flutter_mozilla_components.history.TabScopedHistoryDelegate
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.selector.normalTabs
import mozilla.components.browser.state.selector.privateTabs
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import mozilla.components.support.base.log.logger.Logger

/**
 * Binds per-tab session state at the earliest point the store exposes an
 * EngineSession. This keeps history attribution and restored container UA tied
 * to the same tab/session lifecycle before downstream engine linking continues.
 *
 * Container UA is read from WebLibre's existing per-profile `tab.db` rather than
 * introducing another persistence channel. The lookup is only used when a
 * session is linked; normal new-tab creation already prepares its UA before the
 * first navigation.
 */
class HistoryDelegateBindingMiddleware(
    private val storageDelegate: HistoryTrackingDelegate,
) : Middleware<BrowserState, BrowserAction> {

    private val logger = Logger("HistoryDelegateBindingMiddleware")

    private val profileContext by lazy(LazyThreadSafetyMode.NONE) {
        GlobalComponents.components?.profileApplicationContext
    }

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is EngineAction.LinkEngineSessionAction -> {
                val session = store.state.findTabOrCustomTab(action.tabId)
                bind(
                    store = store,
                    tabId = action.tabId,
                    contextId = session?.contextId,
                    parentId = (session as? TabSessionState)?.parentId,
                    engineSession = action.engineSession,
                )
            }

            // A session opened by the engine itself (`window.open`) arrives with
            // its engine session already attached and already navigating.
            is TabListAction.AddTabAction -> {
                action.tab.engineState.engineSession?.let { engineSession ->
                    bind(
                        store = store,
                        tabId = action.tab.id,
                        contextId = action.tab.contextId,
                        parentId = action.tab.parentId,
                        engineSession = engineSession,
                    )
                }
            }

            is TabListAction.RemoveTabAction -> HistoryExclusions.forget(action.tabId)
            is TabListAction.RemoveTabsAction ->
                action.tabIds.forEach { HistoryExclusions.forget(it) }
            is TabListAction.RemoveAllTabsAction -> HistoryExclusions.forgetAll()
            // Only the tabs actually being removed, read before [next] applies the
            // action. Forgetting the whole set would drop the provisional mark of a
            // surviving tab WebLibre has no row for yet — an excluded container's
            // `window.open` child — and its next visit would reach Places.
            is TabListAction.RemoveAllNormalTabsAction ->
                store.state.normalTabs.forEach { HistoryExclusions.forget(it.id) }
            is TabListAction.RemoveAllPrivateTabsAction ->
                store.state.privateTabs.forEach { HistoryExclusions.forget(it.id) }

            else -> { /* no-op */ }
        }

        next(action)
    }

    private fun bind(
        store: Store<BrowserState, BrowserAction>,
        tabId: String,
        contextId: String?,
        parentId: String?,
        engineSession: EngineSession,
    ) {
        inheritExclusion(store.state, tabId, parentId)

        try {
            engineSession.settings.historyTrackingDelegate =
                TabScopedHistoryDelegate(tabId, contextId, storageDelegate)
        } catch (e: UnsupportedOperationException) {
            // Only an engine that doesn't support per-session history settings can
            // land here; the engine-wide default keeps recording for it.
            logger.error("Failed to bind tab-scoped history delegate for $tabId", e)
        }

        // Restored sessions are created by Android Components from TabSessionState
        // before this middleware sees the LinkEngineSessionAction. The container
        // row is persisted in the same profile-scoped tab.db used by Dart, so we
        // can restore the session UA without a second database, recovery Pigeon
        // field, or upstream Android Components fork.
        val startedAt = SystemClock.elapsedRealtime()
        logger.debug(
            "UA restore bind start tabId=$tabId contextId=$contextId profile=" +
                (profileContext?.relativePath ?: "<none>")
        )

        val currentProfileContext = profileContext
        if (currentProfileContext == null) {
            logger.warn("UA restore bind skipped: no active profile context tabId=$tabId contextId=$contextId")
            return
        }

        val userAgent = ContainerUserAgentStore.get(currentProfileContext, contextId)
        logger.debug(
            "UA restore lookup tabId=$tabId contextId=$contextId found=${userAgent != null} " +
                "elapsedMs=${SystemClock.elapsedRealtime() - startedAt}"
        )

        if (userAgent != null) {
            try {
                engineSession.settings.userAgentString = userAgent
                logger.debug(
                    "UA restore applied tabId=$tabId contextId=$contextId " +
                        "effective=${runCatching { engineSession.settings.userAgentString == userAgent }.getOrDefault(false)} " +
                        "elapsedMs=${SystemClock.elapsedRealtime() - startedAt}"
                )
            } catch (e: UnsupportedOperationException) {
                logger.error("Failed to bind persisted container UA for $tabId", e)
            }
        }
    }

    /**
     * Carry the opener's exclusion over to a session WebLibre hasn't recorded yet.
     * The child inherits the parent's container in Dart moments later; until that
     * snapshot arrives this is the only thing standing between an excluded
     * container's popup and Places. Provisional — see [HistoryExclusions].
     */
    private fun inheritExclusion(state: BrowserState, tabId: String, parentId: String?) {
        // Once the snapshot covers the tab it is the authority, and a mark added
        // here would only be dead weight the next snapshot has to clear. Note the
        // check is "tracked", not "excluded": a *known non-excluded* tab must not
        // be re-marked on every re-link either.
        if (parentId == null || HistoryExclusions.isTracked(tabId)) {
            return
        }

        val parent: SessionState = state.findTabOrCustomTab(parentId) ?: return
        if (HistoryExclusions.isExcluded(parent.id, parent.contextId)) {
            HistoryExclusions.markProvisional(tabId)
        }
    }
}
