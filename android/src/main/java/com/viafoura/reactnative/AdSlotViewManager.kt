package com.viafoura.reactnative

import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp

class AdSlotViewManager : ViewGroupManager<AdSlotView>() {
  override fun getName(): String = "ViafouraAdSlot"

  override fun createViewInstance(reactContext: ThemedReactContext) = AdSlotView(reactContext)

  @ReactProp(name = "position", defaultInt = 0)
  fun setPosition(view: AdSlotView, value: Int) {
    view.position = value
  }

  @ReactProp(name = "adHeight", defaultInt = 0)
  fun setAdHeight(view: AdSlotView, value: Int) {
    view.adHeight = value
  }
}
