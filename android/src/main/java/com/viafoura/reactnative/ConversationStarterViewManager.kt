package com.viafoura.reactnative

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class ConversationStarterViewManager : SimpleViewManager<ConversationStarterView>() {
  override fun getName(): String = "ConversationStarter"

  override fun createViewInstance(reactContext: ThemedReactContext) =
    ConversationStarterView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes(
      "onHeightChanged",
      "onAuthNeeded",
      "onOpenProfile",
      "onNewComment",
      "onSeeMoreComments",
      "onAction"
    )

  @ReactProp(name = "containerId")
  fun setContainerId(view: ConversationStarterView, value: String?) {
    view.containerId = value
  }

  @ReactProp(name = "articleUrl")
  fun setArticleUrl(view: ConversationStarterView, value: String?) {
    view.articleUrl = value
  }

  @ReactProp(name = "articleTitle")
  fun setArticleTitle(view: ConversationStarterView, value: String?) {
    view.articleTitle = value
  }

  @ReactProp(name = "articleSubtitle")
  fun setArticleSubtitle(view: ConversationStarterView, value: String?) {
    view.articleSubtitle = value
  }

  @ReactProp(name = "articleThumbnailUrl")
  fun setArticleThumbnailUrl(view: ConversationStarterView, value: String?) {
    view.articleThumbnailUrl = value
  }

  @ReactProp(name = "syndicationKey")
  fun setSyndicationKey(view: ConversationStarterView, value: String?) {
    view.syndicationKey = value
  }

  @ReactProp(name = "title")
  fun setTitle(view: ConversationStarterView, value: String?) {
    view.starterTitle = value
  }

  @ReactProp(name = "description")
  fun setDescription(view: ConversationStarterView, value: String?) {
    view.starterDescription = value
  }

  @ReactProp(name = "minimumCommentCount")
  fun setMinimumCommentCount(view: ConversationStarterView, value: Int) {
    view.minimumCommentCount = value
  }

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: ConversationStarterView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: ConversationStarterView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: ConversationStarterView, value: ReadableMap?) {
    view.colors = value?.toHashMap()
  }
}
