package expo.modules.viafourasdk

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class PreviewCommentsModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("PreviewComments")

    View(PreviewCommentsView::class) {
      // Props
      Prop("containerId") { view: PreviewCommentsView, v: String -> view.containerId = v }
      Prop("authorId") { view: PreviewCommentsView, v: String? -> view.authorId = v }
      Prop("articleUrl") { view: PreviewCommentsView, v: String -> view.articleUrl = v }
      Prop("articleTitle") { view: PreviewCommentsView, v: String -> view.articleTitle = v }
      Prop("articleSubtitle") { view: PreviewCommentsView, v: String? -> view.articleSubtitle = v }
      Prop("articleThumbnailUrl") { view: PreviewCommentsView, v: String -> view.articleThumbnailUrl = v }
      Prop("syndicationKey") { view: PreviewCommentsView, v: String? -> view.syndicationKey = v }
      Prop("darkMode") { view: PreviewCommentsView, v: Boolean? -> view.darkMode = v ?: false }
      Prop("colors") { view: PreviewCommentsView, v: Map<String, Any?>? -> view.colors = v }

      // Events
      Events("onHeightChanged", "onAuthNeeded", "onOpenProfile", "onNewComment", "onArticlePressed", "onAction")
    }
  }
}
