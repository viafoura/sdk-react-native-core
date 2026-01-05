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

      // Events
      Events("onAuthNeeded", "onCloseProfile")
    }
  }
}

