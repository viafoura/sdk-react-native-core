package expo.modules.viafourasdk

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class NewCommentModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("NewComment")

    View(NewCommentView::class) {
      // Props
      Prop("newCommentActionType") { view: NewCommentView, v: String -> view.newCommentActionType = v }
      Prop("content") { view: NewCommentView, v: String? -> view.content = v }
      Prop("containerId") { view: NewCommentView, v: String -> view.containerId = v }
      Prop("syndicationKey") { view: NewCommentView, v: String? -> view.syndicationKey = v }
      Prop("articleTitle") { view: NewCommentView, v: String -> view.articleTitle = v }
      Prop("articleSubtitle") { view: NewCommentView, v: String? -> view.articleSubtitle = v }
      Prop("articleUrl") { view: NewCommentView, v: String -> view.articleUrl = v }
      Prop("articleThumbnailUrl") { view: NewCommentView, v: String -> view.articleThumbnailUrl = v }
      Prop("darkMode") { view: NewCommentView, v: Boolean? -> view.darkMode = v ?: false }
      Prop("colors") { view: NewCommentView, v: Map<String, Any?>? -> view.colors = v }

      // Events
      Events("onAuthNeeded", "onCloseNewComment", "onHeightChanged", "onAction")
    }
  }
}
