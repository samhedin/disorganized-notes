package com.disorganized.disorganized

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import org.json.JSONArray
import android.content.Intent


data class Section(
    val id: String,
    val content: List<ListItem>
)

data class ListItem(
    val id: String,
    val data: String
)

class InteractiveAction : ActionCallback {
    companion object {
        val NOTE_ID = ActionParameters.Key<String>("noteId")
    }

    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val noteId = parameters.get(NOTE_ID) ?: return

        val uri = Uri.parse("disorganized://openNote?noteId=$noteId")

        val intent = Intent(Intent.ACTION_VIEW, uri).apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        try {
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e("InteractiveAction", "Failed to start activity with intent", e)
        }
    }

}

class NoteWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()
    private val TAG = "NoteWidget-Configure"

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val data = currentState.preferences
        val noteId = sharedPrefs.getString("flutter.note-id", "")
        val sectionId = sharedPrefs.getString("flutter.section-id", "")
        val widgetColor = sharedPrefs.getString("flutter.widget-color", "black")
        val textSize = sharedPrefs.getString("flutter.widget-text-size", "medium")
        val textColor = sharedPrefs.getString("flutter.widget-text-color", "white")
        val showCheckboxes = sharedPrefs.getString("flutter.widget-show-checkboxes", "yes")

        val sectionstring = data.getString("todo_list", "")
        val section: Section? = try {
            sectionstring?.takeIf { it.isNotBlank() }?.let {
                val json = org.json.JSONObject(it)
                val id = json.getString("id")
                val contentJson = json.getJSONArray("content")
                val content = mutableListOf<ListItem>()
                for (i in 0 until contentJson.length()) {
                    val itemJson = contentJson.getJSONObject(i)
                    val item = ListItem(
                        id = itemJson.getString("id"),
                        data = itemJson.getString("data")
                    )
                    content.add(item)
                }
                Section(id = id, content = content)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing section JSON", e)
            null
        }

        // Determine background color and text color based on widget-color
        val (backgroundColor, finalTextColor) = when (widgetColor) {
            "white" -> Pair(Color.White, Color.Black)
            "black" -> Pair(Color.Black, Color.White)
            "transparent" -> {
                // Only use text-color setting when background is transparent
                val textColorFromSetting = when (textColor) {
                    "black" -> Color.Black
                    "white" -> Color.White
                    else -> Color.White // Default fallback
                }
                Pair(Color.Transparent, textColorFromSetting)
            }
            else -> Pair(Color(0xFF333333), Color.White) // Default fallback
        }

        // Determine text size based on the text-size setting
        val fontSize = when (textSize) {
            "small" -> 12.sp
            "medium" -> 16.sp
            "large" -> 20.sp
            else -> 16.sp // Default fallback
        }

        // Determine if checkboxes should be shown
        val shouldShowCheckboxes = showCheckboxes == "yes"

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(backgroundColor)
                .padding(16.dp)
                .clickable(
                    onClick = actionRunCallback<InteractiveAction>(
                        parameters = actionParametersOf(
                            InteractiveAction.NOTE_ID to (noteId ?: "")
                        )
                    )
                )
        ) {
            if (section == null) {
                Text(
                    text = "1. Create a list section\n2. open settings next to the list header\n3. click the widget icon to set it as widget.",
                    style = TextStyle(
                        fontSize = fontSize,
                        color = ColorProvider(finalTextColor)
                    )
                )
            } else {
                section.content
                    .take(9)
                    .forEach { item ->
                        Row(
                            modifier = GlanceModifier
                                .padding(vertical = 4.dp)
                                .clickable(
                                    onClick = actionRunCallback<ToggleCheckboxAction>(
                                        parameters = actionParametersOf(
                                            ToggleCheckboxAction.ITEM_ID to item.id,
                                            ToggleCheckboxAction.SECTION_ID to section.id,
                                            ToggleCheckboxAction.NOTE_ID to (noteId ?: "")
                                        )
                                    )
                                )
                        ) {
                            if (shouldShowCheckboxes) {
                                Image(
                                    provider = ImageProvider(
                                        android.R.drawable.checkbox_off_background
                                        //android.R.drawable.checkbox_on_background
                                    ),
                                    contentDescription = "Unchecked",
                                    modifier = GlanceModifier.padding(end = 8.dp)
                                )
                            }
                            Text(
                                text = item.data,
                                style = TextStyle(
                                    fontSize = fontSize,
                                    color = ColorProvider(finalTextColor)
                                )
                            )
                        }
                    }
            }
        }
    }
}

class ToggleCheckboxAction : ActionCallback {
    companion object {
        val ITEM_ID = ActionParameters.Key<String>("itemId")
        val SECTION_ID = ActionParameters.Key<String>("sectionId")
        val NOTE_ID = ActionParameters.Key<String>("noteId")
    }

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val itemId = parameters.get(ITEM_ID) ?: return
        val noteId = parameters.get(NOTE_ID) ?: return
        val sectionId = parameters.get(SECTION_ID) ?: return

        // Call the background intent with URI
        val uri = Uri.parse("disorganized://checkboxtoggled")
            .buildUpon()
            .appendQueryParameter("noteId", noteId)
            .appendQueryParameter("sectionId", sectionId)
            .appendQueryParameter("itemId", itemId)
            .build()

        try {
            val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context, uri)
            backgroundIntent.send()
        } catch (e: Exception) {
            Log.e("ToggleCheckboxAction", "Failed to send intent", e)
        }
    }
}