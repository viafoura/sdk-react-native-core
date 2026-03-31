import ExpoModulesCore

public class ViafouraCustomUIModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ViafouraCustomUI")

    Function("setCustomUIStyle") { (viewType: String, style: [String: Any?], theme: String?) in
      let visibility = style["visibility"] as? String
      let backgroundColor = style["backgroundColor"] as? String
      CustomUIViewRegistry.shared.setStyle(
        viewType: viewType,
        visibility: visibility,
        backgroundColor: backgroundColor,
        theme: theme
      )
    }

    Function("clearCustomUIStyle") { (viewType: String, theme: String?) in
      CustomUIViewRegistry.shared.clearStyle(viewType: viewType, theme: theme)
    }
  }
}
