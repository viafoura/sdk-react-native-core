package com.viafoura.reactnative

import android.view.View
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event
import com.facebook.react.uimanager.events.RCTEventEmitter
import kotlin.properties.ReadOnlyProperty
import kotlin.reflect.KProperty

class ViafouraEvent(
  surfaceId: Int,
  viewTag: Int,
  private val name: String,
  private val payload: WritableMap
) : Event<ViafouraEvent>(surfaceId, viewTag) {
  override fun getEventName(): String = name
  override fun getEventData(): WritableMap = payload
}

class ViafouraEventEmitter(private val view: View, private val eventName: String) {
  operator fun invoke(payload: Map<String, Any?>) {
    val reactContext = view.context as? ReactContext ?: return
    val dispatcher =
      UIManagerHelper.getEventDispatcherForReactTag(reactContext, view.id) ?: return
    dispatcher.dispatchEvent(
      ViafouraEvent(
        UIManagerHelper.getSurfaceId(view),
        view.id,
        eventName,
        toWritableMap(payload)
      )
    )
  }

  private fun toWritableMap(payload: Map<String, Any?>): WritableMap {
    val map = Arguments.createMap()
    payload.forEach { (key, value) ->
      when (value) {
        null -> map.putNull(key)
        is Boolean -> map.putBoolean(key, value)
        is Int -> map.putInt(key, value)
        is Long -> map.putDouble(key, value.toDouble())
        is Float -> map.putDouble(key, value.toDouble())
        is Double -> map.putDouble(key, value)
        is String -> map.putString(key, value)
        is Map<*, *> -> {
          @Suppress("UNCHECKED_CAST")
          map.putMap(key, toWritableMap(value as Map<String, Any?>))
        }
        is List<*> -> map.putArray(key, Arguments.fromList(value))
        else -> map.putString(key, value.toString())
      }
    }
    return map
  }
}

class ViafouraEventEmitterDelegate(private val view: View) {
  operator fun provideDelegate(
    thisRef: Any?,
    property: KProperty<*>
  ): ReadOnlyProperty<Any?, ViafouraEventEmitter> {
    val emitter = ViafouraEventEmitter(view, property.name)
    return ReadOnlyProperty { _, _ -> emitter }
  }
}

fun View.viafouraEvent() = ViafouraEventEmitterDelegate(this)

fun eventNamesToDirectEventTypes(vararg names: String): MutableMap<String, Any> {
  val map = mutableMapOf<String, Any>()
  names.forEach { name ->
    map[name] = mapOf("registrationName" to name)
  }
  return map
}

fun View.reactActivity(): android.app.Activity? {
  (context as? ReactContext)?.currentActivity?.let { return it }
  var current: android.content.Context? = context
  while (current is android.content.ContextWrapper) {
    if (current is android.app.Activity) return current
    current = current.baseContext
  }
  return null
}
