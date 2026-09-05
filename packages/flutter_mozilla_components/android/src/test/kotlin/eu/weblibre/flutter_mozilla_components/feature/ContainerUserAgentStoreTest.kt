/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class ContainerUserAgentStoreTest {
    @Test
    fun parsesMatchingContainerUserAgent() {
        val metadata = """
            {"contextualIdentity":"container-a","userAgent":" UA-A "}
        """.trimIndent()

        assertEquals(
            "UA-A",
            ContainerUserAgentStore.parseUserAgent(metadata, "container-a"),
        )
    }

    @Test
    fun ignoresDifferentContainer() {
        val metadata = """
            {"contextualIdentity":"container-a","userAgent":"UA-A"}
        """.trimIndent()

        assertNull(
            ContainerUserAgentStore.parseUserAgent(metadata, "container-b"),
        )
    }

    @Test
    fun treatsBlankUserAgentAsDefault() {
        val metadata = """
            {"contextualIdentity":"container-a","userAgent":"   "}
        """.trimIndent()

        assertNull(
            ContainerUserAgentStore.parseUserAgent(metadata, "container-a"),
        )
    }

    @Test
    fun ignoresMalformedMetadata() {
        assertNull(
            ContainerUserAgentStore.parseUserAgent("not-json", "container-a"),
        )
    }
}
