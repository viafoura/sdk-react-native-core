import UIKit

struct CustomUIStyle {
  let visibility: String?
  let backgroundColor: String?
}

final class CustomUIViewRegistry {
  static let shared = CustomUIViewRegistry()
  private var stylePolicies: [String: CustomUIStyle] = [:]

  private init() {}

  private func policyKey(viewType: String, theme: String?) -> String {
    guard let theme, !theme.isEmpty else { return viewType }
    return "\(viewType)#\(theme.lowercased())"
  }

  func setStyle(viewType: String, visibility: String?, backgroundColor: String?, theme: String?) {
    let key = policyKey(viewType: viewType, theme: theme)
    let existing = stylePolicies[key]
    let merged = CustomUIStyle(
      visibility: visibility ?? existing?.visibility,
      backgroundColor: backgroundColor ?? existing?.backgroundColor
    )
    stylePolicies[key] = merged
  }

  func clearStyle(viewType: String, theme: String?) {
    stylePolicies.removeValue(forKey: policyKey(viewType: viewType, theme: theme))
  }

  func style(viewType: String, theme: String?) -> CustomUIStyle? {
    if let theme {
      if let themed = stylePolicies[policyKey(viewType: viewType, theme: theme)] {
        return themed
      }
    }
    return stylePolicies[policyKey(viewType: viewType, theme: nil)]
  }

  func applyStyle(view: UIView, style: CustomUIStyle) {
    DispatchQueue.main.async {
      if let visibility = style.visibility {
        view.isHidden = (visibility == "hidden")
      }
      if let backgroundColor = style.backgroundColor, let color = self.colorFromHex(backgroundColor) {
        view.backgroundColor = color
      }
    }
  }

  private func colorFromHex(_ value: String) -> UIColor? {
    var hex = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if hex.hasPrefix("#") {
      hex.removeFirst()
    }
    if hex.count == 6 {
      hex = "FF" + hex
    }
    guard hex.count == 8, let hexNumber = UInt64(hex, radix: 16) else {
      return nil
    }
    let alpha = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
    let red = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
    let green = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
    let blue = CGFloat(hexNumber & 0x000000FF) / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
