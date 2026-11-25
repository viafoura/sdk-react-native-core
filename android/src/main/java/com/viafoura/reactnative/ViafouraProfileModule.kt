package com.viafoura.reactnative

import androidx.fragment.app.FragmentActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.viafourasdk.src.model.local.VFProfilePresentationType
import java.util.UUID

class ViafouraProfileModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  companion object {
    const val NAME = "ViafouraProfile"
    const val EVENT_NAME = "ViafouraProfileEvent"
  }

  override fun getName(): String = NAME

  @ReactMethod
  fun addListener(eventName: String) {}

  @ReactMethod
  fun removeListeners(count: Double) {}

  @ReactMethod
  fun presentProfile(presentationId: String, options: ReadableMap, promise: Promise) {
    val rawUUID = if (options.hasKey("userUUID")) options.getString("userUUID") else null
    val userUUID = try {
      UUID.fromString(rawUUID)
    } catch (_: Exception) {
      promise.reject("invalid_uuid", "Invalid UUID: $rawUUID")
      return
    }
    val presentationType =
      if (options.hasKey("presentationType") && options.getString("presentationType") == "feed") {
        VFProfilePresentationType.feed
      } else {
        VFProfilePresentationType.profile
      }
    val sheetOptions = options.toHashMap()

    UiThreadUtil.runOnUiThread {
      val activity = reactContext.currentActivity as? FragmentActivity
      if (activity == null) {
        promise.reject("no_activity", "No activity to present the profile from")
        return@runOnUiThread
      }
      try {
        ProfileSheet(activity, sheetOptions) { event, payload ->
          emit(presentationId, event, payload)
        }.present(userUUID, presentationType)
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("present_failed", e.message, e)
      }
    }
  }

  private fun emit(presentationId: String, event: String, payload: Map<String, Any?>?) {
    if (!reactContext.hasActiveReactInstance()) return
    val body = Arguments.createMap().apply {
      putString("presentationId", presentationId)
      putString("event", event)
      payload?.let { putMap("payload", Arguments.makeNativeMap(it)) }
    }
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(EVENT_NAME, body)
  }
}
