package expo.modules.viafourasdk

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ViafouraCustomUIModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ViafouraCustomUI")

    Function("setCustomUIStyle") { viewType: String, style: Map<String, Any?>, theme: String? ->
      val visibility = style["visibility"] as? String
      val backgroundColor = style["backgroundColor"] as? String
      CustomUIViewRegistry.setStyle(
        viewType,
        CustomUIStyle(visibility = visibility, backgroundColor = backgroundColor),
        theme
      )
    }

    Function("clearCustomUIStyle") { viewType: String, theme: String? ->
      CustomUIViewRegistry.clearStyle(viewType, theme)
    }
  }
}
