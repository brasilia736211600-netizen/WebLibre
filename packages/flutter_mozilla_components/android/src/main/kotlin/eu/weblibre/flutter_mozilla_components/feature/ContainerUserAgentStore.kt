/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteException
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONException
import org.json.JSONObject

/**
 * Reads the container UA directly from WebLibre's existing per-profile Drift
 * database. This keeps cold-start restore on the same source of truth as Dart
 * without adding a second native persistence store or a new Pigeon contract.
 */
internal object ContainerUserAgentStore {
    private const val DATABASE_NAME = "tab.db"
    private const val SQL = "SELECT metadata FROM container"

    private val logger = Logger("container_user_agent")

    internal fun parseUserAgent(
        metadata: String,
        contextualIdentity: String,
    ): String? = try {
        val json = JSONObject(metadata)
        if (json.optString("contextualIdentity", null) != contextualIdentity) {
            return null
        }

        json.optString("userAgent", null)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
    } catch (e: JSONException) {
        null
    }

    fun get(context: Context, contextualIdentity: String?): String? {
        if (contextualIdentity.isNullOrBlank()) {
            logger.debug("UA lookup skipped: blank contextualIdentity")
            return null
        }

        val databaseFile = context.getDatabasePath(DATABASE_NAME)
        if (!databaseFile.exists()) {
            logger.debug("UA lookup skipped: database missing path=${databaseFile.path}")
            return null
        }

        var database: SQLiteDatabase? = null
        var cursor: Cursor? = null
        return try {
            database = SQLiteDatabase.openDatabase(
                databaseFile.path,
                null,
                SQLiteDatabase.OPEN_READONLY,
            )
            cursor = database.rawQuery(SQL, null)

            while (cursor.moveToNext()) {
                val metadata = cursor.getString(0) ?: continue
                val userAgent = parseUserAgent(metadata, contextualIdentity)
                if (userAgent != null) {
                    logger.debug(
                        "UA lookup hit contextId=$contextualIdentity path=${databaseFile.path}"
                    )
                    return userAgent
                }
            }

            logger.debug(
                "UA lookup miss contextId=$contextualIdentity path=${databaseFile.path}"
            )
            null
        } catch (e: SQLiteException) {
            // Startup must remain safe if the Flutter/Drift connection currently
            // owns a transaction or the database is not ready yet. The engine's
            // normal UA remains the safe fallback for a failed lookup.
            logger.warn("Unable to read persisted container UA", e)
            null
        } finally {
            cursor?.close()
            database?.close()
        }
    }
}
