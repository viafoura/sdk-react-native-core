import UIKit

struct CustomUIStyle {
  var visibility: String?
  var backgroundColor: String?
  var textColor: String?
  var tintColor: String?
  var fontFamily: String?
  var fontSize: CGFloat?
  var cornerRadius: CGFloat?
  var borderColor: String?
  var borderWidth: CGFloat?
  var opacity: CGFloat?

  init(dictionary: NSDictionary) {
    visibility = dictionary["visibility"] as? String
    backgroundColor = dictionary["backgroundColor"] as? String
    textColor = dictionary["textColor"] as? String
    tintColor = dictionary["tintColor"] as? String
    fontFamily = dictionary["fontFamily"] as? String
    fontSize = CustomUIStyle.number(dictionary["fontSize"])
    cornerRadius = CustomUIStyle.number(dictionary["cornerRadius"])
    borderColor = dictionary["borderColor"] as? String
    borderWidth = CustomUIStyle.number(dictionary["borderWidth"])
    opacity = CustomUIStyle.number(dictionary["opacity"])
  }

  private static func number(_ value: Any?) -> CGFloat? {
    guard let number = value as? NSNumber else { return nil }
    return CGFloat(truncating: number)
  }

  func merged(over existing: CustomUIStyle?) -> CustomUIStyle {
    guard let existing else { return self }
    var result = self
    result.visibility = visibility ?? existing.visibility
    result.backgroundColor = backgroundColor ?? existing.backgroundColor
    result.textColor = textColor ?? existing.textColor
    result.tintColor = tintColor ?? existing.tintColor
    result.fontFamily = fontFamily ?? existing.fontFamily
    result.fontSize = fontSize ?? existing.fontSize
    result.cornerRadius = cornerRadius ?? existing.cornerRadius
    result.borderColor = borderColor ?? existing.borderColor
    result.borderWidth = borderWidth ?? existing.borderWidth
    result.opacity = opacity ?? existing.opacity
    return result
  }
}

final class CustomUIViewRegistry {
  static let shared = CustomUIViewRegistry()
  private var stylePolicies: [String: CustomUIStyle] = [:]

  private init() {}

  private func policyKey(viewType: String, theme: String?) -> String {
    guard let theme, !theme.isEmpty else { return viewType }
    return "\(viewType)#\(theme.lowercased())"
  }

  func setStyle(viewType: String, style: CustomUIStyle, theme: String?) {
    let key = policyKey(viewType: viewType, theme: theme)
    stylePolicies[key] = style.merged(over: stylePolicies[key])
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
      self.apply(style, to: view)
    }
  }

  private func apply(_ style: CustomUIStyle, to view: UIView) {
    if let visibility = style.visibility {
      view.isHidden = (visibility == "hidden")
    }
    if let backgroundColor = style.backgroundColor, let color = colorFromHex(backgroundColor) {
      view.backgroundColor = color
    }
    if let textColor = style.textColor, let color = colorFromHex(textColor) {
      applyTextColor(color, to: view)
    }
    if let tintColor = style.tintColor, let color = colorFromHex(tintColor) {
      if let imageView = view as? UIImageView {
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
      }
      view.tintColor = color
    }
    if style.fontFamily != nil || style.fontSize != nil {
      applyFont(family: style.fontFamily, size: style.fontSize, to: view)
    }
    if let cornerRadius = style.cornerRadius {
      view.layer.cornerRadius = cornerRadius
      view.clipsToBounds = cornerRadius > 0 || view.clipsToBounds
    }
    if let borderColor = style.borderColor, let color = colorFromHex(borderColor) {
      view.layer.borderColor = color.cgColor
    }
    if let borderWidth = style.borderWidth {
      view.layer.borderWidth = borderWidth
    }
    if let opacity = style.opacity {
      view.alpha = min(max(opacity, 0), 1)
    }
  }

  private func applyTextColor(_ color: UIColor, to view: UIView) {
    switch view {
    case let label as UILabel:
      label.textColor = color
    case let textView as UITextView:
      textView.textColor = color
    case let textField as UITextField:
      textField.textColor = color
    case let button as UIButton:
      button.setTitleColor(color, for: .normal)
    default:
      break
    }
  }

  private func applyFont(family: String?, size: CGFloat?, to view: UIView) {
    func resolve(_ current: UIFont?) -> UIFont? {
      let base = current ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)
      let pointSize = size ?? base.pointSize
      if let family, !family.isEmpty, let named = UIFont(name: family, size: pointSize) {
        return named
      }
      return base.withSize(pointSize)
    }
    switch view {
    case let label as UILabel:
      label.font = resolve(label.font)
    case let textView as UITextView:
      textView.font = resolve(textView.font)
    case let textField as UITextField:
      textField.font = resolve(textField.font)
    case let button as UIButton:
      button.titleLabel?.font = resolve(button.titleLabel?.font)
    default:
      break
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
