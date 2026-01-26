package expo.modules.viafourasdk

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ProfileModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Profile")

    View(ProfileView::class) {
      // Props
      Prop("userUUID") { view: ProfileView, v: String -> view.userUUID = v }
      Prop("presentationType") { view: ProfileView, v: String? -> view.presentationType = v }
      Prop("darkMode") { view: ProfileView, v: Boolean? -> view.darkMode = v ?: false }
      Prop("theme") { view: ProfileView, v: String? -> view.theme = v }
      Prop("colors") { view: ProfileView, v: Map<String, Any?>? -> view.colors = v }

      // Events
      Events("onAuthNeeded", "onCloseProfile", "onAction")
    }
  }
}
