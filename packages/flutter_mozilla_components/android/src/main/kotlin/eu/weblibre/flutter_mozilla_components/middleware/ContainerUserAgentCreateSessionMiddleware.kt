/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.feature.ContainerUserAgentStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.EngineState
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import mozilla.components.support.base.log.logger.Logger

/**
 * Creates restored engine sessions with the container UA already applied.
 *
 * Android Components restores [EngineSessionState] while creating the session,
 * before its later LinkEngineSessionAction reaches application middleware. A
 * UA assigned only from LinkEngineSessionAction is therefore too late for the
 * first restored navigation. This middleware owns the same narrow creation
 * boundary as Android Components' CreateEngineSessionMiddleware so the
 * persisted container UA is installed immediately after createSession() and
 * before restoreState()/any navigation can use the session.
 */
class ContainerUserAgentCreateSessionMiddleware(
    private val engine: Engine,
    private val profileContext: ProfileContext,
    private val scope: CoroutineScope,
) : Middleware<BrowserState, BrowserAction> {

    private val logger = Logger("ContainerUserAgentCreateSessionMiddleware")

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        if (action !is EngineAction.CreateEngineSessionAction) {
            next(action)
            return
        }

        val tab = store.state.findTabOrCustomTab(action.tabId)
        val engineState = tab?.engineState
        if (engineState?.initializing == false &&
            engineState.engineSession == null &&
            !engineState.crashed
        ) {
            store.dispatch(
                EngineAction.UpdateEngineSessionInitializingAction(action.tabId, true),
            )
            scope.launch {
                createEngineSession(store, action, tab.id, tab.contextId, tab.content.private, engineState)
                action.followupAction?.let { store.dispatch(it) }
            }
        } else {
            // Match Android Components behavior for an already-initializing,
            // already-created, or crashed tab: the follow-up can still run.
            action.followupAction?.let { scope.launch { store.dispatch(it) } }
        }
    }

    private fun createEngineSession(
        store: Store<BrowserState, BrowserAction>,
        action: EngineAction.CreateEngineSessionAction,
        tabId: String,
        contextId: String?,
        privateMode: Boolean,
        engineState: EngineState,
    ) {
        logger.debug("Request to create engine session for tab $tabId")

        val engineSession = engine.createSession(privateMode, contextId)
        val persistedUserAgent = ContainerUserAgentStore.get(profileContext, contextId)

        applyUserAgent(engineSession, tabId, contextId, persistedUserAgent)

        val skipLoading = engineState.engineSessionState?.let {
            engineSession.restoreState(it)
        } ?: false

        // Keep the setting explicit after state restoration as well. This is still
        // before the LinkEngineSessionAction can trigger a load when skipLoading is
        // false, and protects the intended setting from an engine implementation
        // that changes session settings during state restoration.
        applyUserAgent(engineSession, tabId, contextId, persistedUserAgent)

        store.dispatch(
            EngineAction.LinkEngineSessionAction(
                tabId = tabId,
                engineSession = engineSession,
                skipLoading = skipLoading,
            ),
        )
    }

    private fun applyUserAgent(
        engineSession: EngineSession,
        tabId: String,
        contextId: String?,
        userAgent: String?,
    ) {
        if (userAgent == null) return

        try {
            engineSession.settings.userAgentString = userAgent
            logger.debug(
                "UA pre-restore bind tabId=$tabId contextId=$contextId " +
                    "effective=${runCatching { engineSession.settings.userAgentString == userAgent }.getOrDefault(false)}",
            )
        } catch (e: UnsupportedOperationException) {
            logger.error("Failed to apply persisted container UA for $tabId", e)
        }
    }
}
