import React

@objc(ViafouraCustomUI)
public class ViafouraCustomUIModule: NSObject {
  @objc
  public static func requiresMainQueueSetup() -> Bool {
    return false
  }

  @objc(setCustomUIStyle:style:theme:)
  public func setCustomUIStyle(_ viewType: String, style: NSDictionary, theme: String?) {
    let visibility = style["visibility"] as? String
    let backgroundColor = style["backgroundColor"] as? String
    CustomUIViewRegistry.shared.setStyle(
      viewType: viewType,
      visibility: visibility,
      backgroundColor: backgroundColor,
      theme: theme
    )
  }

  @objc(clearCustomUIStyle:theme:)
  public func clearCustomUIStyle(_ viewType: String, theme: String?) {
    CustomUIViewRegistry.shared.clearStyle(viewType: viewType, theme: theme)
  }
}
