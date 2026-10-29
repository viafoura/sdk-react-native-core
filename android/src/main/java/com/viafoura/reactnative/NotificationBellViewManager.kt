package com.viafoura.reactnative

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class NotificationBellViewManager : SimpleViewManager<NotificationBellView>() {
  override fun getName(): String = "ViafouraNotificationBell"

  override fun createViewInstance(reactContext: ThemedReactContext) = NotificationBellView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes("onBellPressed", "onAuthNeeded", "onAction")

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: NotificationBellView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: NotificationBellView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: NotificationBellView, value: ReadableMap?) {
    view.colors = value?.toHashMap()
  }

  @ReactProp(name = "fonts")
  fun setFonts(view: NotificationBellView, value: ReadableMap?) {
    view.fonts = value?.toHashMap()
  }

  @ReactProp(name = "elevationEnabled")
  fun setElevationEnabled(view: NotificationBellView, value: Boolean) {
    view.elevationEnabled = value
  }

  @ReactProp(name = "backgroundColorEnabled", defaultBoolean = true)
  fun setBackgroundColorEnabled(view: NotificationBellView, value: Boolean) {
    view.backgroundColorEnabled = value
  }
}
