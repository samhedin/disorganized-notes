package com.disorganized.disorganized
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class NoteWidgetReceiver : HomeWidgetGlanceWidgetReceiver<NoteWidget>() {
    override val glanceAppWidget = NoteWidget()
}
