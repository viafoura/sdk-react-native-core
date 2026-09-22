package com.viafoura.reactnative

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class LiveQuestionsViewManager : SimpleViewManager<LiveQuestionsView>() {
  override fun getName(): String = "LiveQuestions"

  override fun createViewInstance(reactContext: ThemedReactContext) = LiveQuestionsView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes(
      "onHeightChanged",
      "onAuthNeeded",
      "onOpenProfile",
      "onAction"
    )

  @ReactProp(name = "containerId")
  fun setContainerId(view: LiveQuestionsView, value: String?) {
    view.containerId = value
  }

  @ReactProp(name = "authorId")
  fun setAuthorId(view: LiveQuestionsView, value: String?) {
    view.authorId = value
  }

  @ReactProp(name = "articleUrl")
  fun setArticleUrl(view: LiveQuestionsView, value: String?) {
    view.articleUrl = value
  }

  @ReactProp(name = "articleTitle")
  fun setArticleTitle(view: LiveQuestionsView, value: String?) {
    view.articleTitle = value
  }

  @ReactProp(name = "articleSubtitle")
  fun setArticleSubtitle(view: LiveQuestionsView, value: String?) {
    view.articleSubtitle = value
  }

  @ReactProp(name = "articleThumbnailUrl")
  fun setArticleThumbnailUrl(view: LiveQuestionsView, value: String?) {
    view.articleThumbnailUrl = value
  }

  @ReactProp(name = "focusedContentUUID")
  fun setFocusedContentUUID(view: LiveQuestionsView, value: String?) {
    view.focusedContentUUID = value
  }

  @ReactProp(name = "limit")
  fun setLimit(view: LiveQuestionsView, value: Int) {
    view.limit = if (value > 0) value else null
  }

  @ReactProp(name = "replyLimit")
  fun setReplyLimit(view: LiveQuestionsView, value: Int) {
    view.replyLimit = if (value > 0) value else null
  }

  @ReactProp(name = "title")
  fun setTitle(view: LiveQuestionsView, value: String?) {
    view.liveQuestionsTitle = value
  }

  @ReactProp(name = "sectionUUID")
  fun setSectionUUID(view: LiveQuestionsView, value: String?) {
    view.sectionUUID = value
  }

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: LiveQuestionsView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: LiveQuestionsView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: LiveQuestionsView, value: ReadableMap?) {
    view.colors = value?.toHashMap()
  }
}
