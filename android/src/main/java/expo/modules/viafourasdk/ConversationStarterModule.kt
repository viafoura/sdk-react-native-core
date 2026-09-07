package expo.modules.viafourasdk

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ConversationStarterModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ConversationStarter")

    View(ConversationStarterView::class) {
      // Props
      Prop("containerId") { view: ConversationStarterView, v: String -> view.containerId = v }
      Prop("articleUrl") { view: ConversationStarterView, v: String -> view.articleUrl = v }
      Prop("articleTitle") { view: ConversationStarterView, v: String -> view.articleTitle = v }
      Prop("articleSubtitle") { view: ConversationStarterView, v: String? -> view.articleSubtitle = v }
      Prop("articleThumbnailUrl") { view: ConversationStarterView, v: String -> view.articleThumbnailUrl = v }
      Prop("syndicationKey") { view: ConversationStarterView, v: String? -> view.syndicationKey = v }
      Prop("title") { view: ConversationStarterView, v: String? -> view.starterTitle = v }
      Prop("description") { view: ConversationStarterView, v: String? -> view.starterDescription = v }
      Prop("minimumCommentCount") { view: ConversationStarterView, v: Int? -> view.minimumCommentCount = v }
      Prop("darkMode") { view: ConversationStarterView, v: Boolean? -> view.darkMode = v ?: false }
      Prop("theme") { view: ConversationStarterView, v: String? -> view.theme = v }
      Prop("colors") { view: ConversationStarterView, v: Map<String, Any?>? -> view.colors = v }

      // Events
      Events(
        "onHeightChanged",
        "onAuthNeeded",
        "onOpenProfile",
        "onNewComment",
        "onSeeMoreComments",
        "onAction"
      )
    }
  }
}
