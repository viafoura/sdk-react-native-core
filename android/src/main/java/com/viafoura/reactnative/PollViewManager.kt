package com.viafoura.reactnative

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class PollViewManager : SimpleViewManager<PollView>() {
  override fun getName(): String = "ViafouraPoll"

  override fun createViewInstance(reactContext: ThemedReactContext) = PollView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes(
      "onHeightChanged",
      "onAuthNeeded",
      "onAction"
    )

  @ReactProp(name = "containerId")
  fun setContainerId(view: PollView, value: String?) {
    view.containerId = value
  }

  @ReactProp(name = "contentContainerUUID")
  fun setContentContainerUUID(view: PollView, value: String?) {
    view.contentContainerUUID = value
  }

  @ReactProp(name = "sectionUUID")
  fun setSectionUUID(view: PollView, value: String?) {
    view.sectionUUID = value
  }

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: PollView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: PollView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: PollView, value: ReadableMap?) {
    view.colors = value?.toHashMap()
  }

  @ReactProp(name = "fonts")
  fun setFonts(view: PollView, value: ReadableMap?) {
    view.fonts = value?.toHashMap()
  }
}
