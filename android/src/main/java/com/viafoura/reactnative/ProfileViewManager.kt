package com.viafoura.reactnative

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class ProfileViewManager : SimpleViewManager<ProfileView>() {
  override fun getName(): String = "Profile"

  override fun createViewInstance(reactContext: ThemedReactContext) = ProfileView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes("onAuthNeeded", "onCloseProfile", "onAction")

  @ReactProp(name = "userUUID")
  fun setUserUUID(view: ProfileView, value: String?) {
    view.userUUID = value
  }

  @ReactProp(name = "presentationType")
  fun setPresentationType(view: ProfileView, value: String?) {
    view.presentationType = value
  }

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: ProfileView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: ProfileView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: ProfileView, value: ReadableMap?) {
    view.colors = value?.toHashMap()
  }
}
