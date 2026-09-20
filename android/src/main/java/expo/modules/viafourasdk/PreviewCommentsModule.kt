package expo.modules.viafourasdk

import android.view.View
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
      Prop("theme") { view: PreviewCommentsView, v: String? -> view.theme = v }
      Prop("colors") { view: PreviewCommentsView, v: Map<String, Any?>? -> view.colors = v }
      Prop("adInterval") { view: PreviewCommentsView, v: Int? -> view.adInterval = v ?: 0 }
      Prop("firstAdPosition") { view: PreviewCommentsView, v: Int? -> view.firstAdPosition = v ?: 2 }

      // Events
      Events(
        "onHeightChanged",
        "onAuthNeeded",
        "onOpenProfile",
        "onNewComment",
        "onArticlePressed",
        "onAction",
        "onAdSlotRequested"
      )

      GroupView<PreviewCommentsView> {
        AddChildView { parent: PreviewCommentsView, child: View, index: Int ->
          parent.addReactChild(child, index)
        }
        GetChildCount { parent: PreviewCommentsView -> parent.reactChildCount }
        GetChildViewAt { parent: PreviewCommentsView, index: Int -> parent.reactChildAt(index) }
        RemoveChildViewAt { parent: PreviewCommentsView, index: Int -> parent.removeReactChildAt(index) }
        RemoveChildView { parent: PreviewCommentsView, child: View -> parent.removeReactChild(child) }
      }
    }
  }
}
