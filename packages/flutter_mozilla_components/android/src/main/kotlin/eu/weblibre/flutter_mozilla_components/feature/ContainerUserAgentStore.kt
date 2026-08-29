/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteException
import android.content.Context
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
    private const val SQL =
        "SELECT metadata FROM container " +
            "WHERE json_extract(metadata, '$.contextualIdentity') = ? LIMIT 1"

    private val logger = Logger("container_user_agent")

    fun get(context: Context, contextualIdentity: String?): String? {
        if (contextualIdentity.isNullOrBlank()) return null

        val databaseFile = context.getDatabasePath(DATABASE_NAME)
        if (!databaseFile.exists()) return null

        var database: SQLiteDatabase? = null
        var cursor: Cursor? = null
        return try {
            database = SQLiteDatabase.openDatabase(
                databaseFile.path,
                null,
                SQLiteDatabase.OPEN_READONLY,
            )
            cursor = database.rawQuery(SQL, arrayOf(contextualIdentity))
            if (!cursor.moveToFirst()) return null

            val metadata = cursor.getString(0) ?: return null
            val userAgent = JSONObject(metadata).optString("userAgent", null)
            userAgent?.trim()?.takeIf { it.isNotEmpty() }
        } catch (e: SQLiteException) {
            // Startup must remain safe if the Flutter/Drift connection currently
            // owns a transaction or the database is not ready yet. The engine's
            // normal UA remains the safe fallback for a failed lookup.
            logger.warn("Unable to read persisted container UA", e)
            null
        } catch (e: JSONException) {
            logger.warn("Unable to parse persisted container metadata", e)
            null
        } finally {
            cursor?.close()
            database?.close()
        }
    }
}
