package com.viafoura.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap

class ViafouraCustomUIModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String = "ViafouraCustomUI"

  @ReactMethod
  fun setCustomUIStyle(viewType: String, style: ReadableMap, theme: String?) {
    val visibility = if (style.hasKey("visibility")) style.getString("visibility") else null
    val backgroundColor =
      if (style.hasKey("backgroundColor")) style.getString("backgroundColor") else null
    CustomUIViewRegistry.setStyle(
      viewType,
      CustomUIStyle(visibility = visibility, backgroundColor = backgroundColor),
      theme
    )
  }

  @ReactMethod
  fun clearCustomUIStyle(viewType: String, theme: String?) {
    CustomUIViewRegistry.clearStyle(viewType, theme)
  }
}
