package com.viafoura.reactnative

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class NewCommentViewManager : SimpleViewManager<NewCommentView>() {
  override fun getName(): String = "NewComment"

  override fun createViewInstance(reactContext: ThemedReactContext) = NewCommentView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes(
      "onAuthNeeded",
      "onCloseNewComment",
      "onHeightChanged",
      "onAction"
    )

  @ReactProp(name = "newCommentActionType")
  fun setNewCommentActionType(view: NewCommentView, value: String?) {
    view.newCommentActionType = value ?: "create"
  }

  @ReactProp(name = "content")
  fun setContent(view: NewCommentView, value: String?) {
    view.content = value
  }

  @ReactProp(name = "containerId")
  fun setContainerId(view: NewCommentView, value: String?) {
    view.containerId = value
  }

  @ReactProp(name = "syndicationKey")
  fun setSyndicationKey(view: NewCommentView, value: String?) {
    view.syndicationKey = value
  }

  @ReactProp(name = "articleTitle")
  fun setArticleTitle(view: NewCommentView, value: String?) {
    view.articleTitle = value
  }

  @ReactProp(name = "articleSubtitle")
  fun setArticleSubtitle(view: NewCommentView, value: String?) {
    view.articleSubtitle = value
  }

  @ReactProp(name = "articleUrl")
  fun setArticleUrl(view: NewCommentView, value: String?) {
    view.articleUrl = value
  }

  @ReactProp(name = "articleThumbnailUrl")
  fun setArticleThumbnailUrl(view: NewCommentView, value: String?) {
    view.articleThumbnailUrl = value
  }

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: NewCommentView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: NewCommentView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: NewCommentView, value: ReadableMap?) {
    view.colors = value?.toHashMap()
  }
}
