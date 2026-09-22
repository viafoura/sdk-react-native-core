package com.viafoura.reactnative

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class ViafouraPackage : ReactPackage {
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> =
    listOf(
      ViafouraModule(reactContext),
      ViafouraCustomUIModule(reactContext)
    )

  override fun createViewManagers(
    reactContext: ReactApplicationContext
  ): List<ViewManager<*, *>> =
    listOf(
      PreviewCommentsViewManager(),
      ProfileViewManager(),
      NewCommentViewManager(),
      ConversationStarterViewManager(),
      LiveQuestionsViewManager(),
      AdSlotViewManager()
    )
}
