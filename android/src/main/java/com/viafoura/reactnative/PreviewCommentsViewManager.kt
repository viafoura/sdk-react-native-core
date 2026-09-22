package com.viafoura.reactnative

import android.view.View
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp

class PreviewCommentsViewManager : ViewGroupManager<PreviewCommentsView>() {
  override fun getName(): String = "PreviewComments"

  override fun createViewInstance(reactContext: ThemedReactContext) =
    PreviewCommentsView(reactContext)

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> =
    eventNamesToDirectEventTypes(
      "onHeightChanged",
      "onAuthNeeded",
      "onOpenProfile",
      "onNewComment",
      "onArticlePressed",
      "onAction",
      "onAdSlotRequested"
    )

  @ReactProp(name = "containerId")
  fun setContainerId(view: PreviewCommentsView, value: String?) {
    view.containerId = value
  }

  @ReactProp(name = "authorId")
  fun setAuthorId(view: PreviewCommentsView, value: String?) {
    view.authorId = value
  }

  @ReactProp(name = "articleUrl")
  fun setArticleUrl(view: PreviewCommentsView, value: String?) {
    view.articleUrl = value
  }

  @ReactProp(name = "articleTitle")
  fun setArticleTitle(view: PreviewCommentsView, value: String?) {
    view.articleTitle = value
  }

  @ReactProp(name = "articleSubtitle")
  fun setArticleSubtitle(view: PreviewCommentsView, value: String?) {
    view.articleSubtitle = value
  }

  @ReactProp(name = "articleThumbnailUrl")
  fun setArticleThumbnailUrl(view: PreviewCommentsView, value: String?) {
    view.articleThumbnailUrl = value
  }

  @ReactProp(name = "syndicationKey")
  fun setSyndicationKey(view: PreviewCommentsView, value: String?) {
    view.syndicationKey = value
  }

  @ReactProp(name = "darkMode")
  fun setDarkMode(view: PreviewCommentsView, value: Boolean) {
    view.darkMode = value
  }

  @ReactProp(name = "theme")
  fun setTheme(view: PreviewCommentsView, value: String?) {
    view.theme = value
  }

  @ReactProp(name = "colors")
  fun setColors(view: PreviewCommentsView, value: com.facebook.react.bridge.ReadableMap?) {
    view.colors = value?.toHashMap()
  }

  @ReactProp(name = "adInterval", defaultInt = 0)
  fun setAdInterval(view: PreviewCommentsView, value: Int) {
    view.adInterval = value
  }

  @ReactProp(name = "firstAdPosition", defaultInt = 2)
  fun setFirstAdPosition(view: PreviewCommentsView, value: Int) {
    view.firstAdPosition = value
  }

  override fun addView(parent: PreviewCommentsView, child: View, index: Int) {
    parent.addReactChild(child, index)
  }

  override fun getChildCount(parent: PreviewCommentsView): Int = parent.reactChildCount

  override fun getChildAt(parent: PreviewCommentsView, index: Int): View? =
    parent.reactChildAt(index)

  override fun removeViewAt(parent: PreviewCommentsView, index: Int) {
    parent.removeReactChildAt(index)
  }
}
