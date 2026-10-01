import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

func resolveVFFonts(_ fonts: [String: Any]) -> VFFonts {
  func font(_ key: String, default defaultFont: UIFont) -> UIFont {
    guard let name = fonts[key] as? String, !name.isEmpty else { return defaultFont }
    return UIFont(name: name, size: defaultFont.pointSize) ?? defaultFont
  }
  return VFFonts(
    fontLight: font("fontLight", default: VFFonts.fontLightDefault),
    fontRegular: font("fontRegular", default: VFFonts.fontRegularDefault),
    fontMedium: font("fontMedium", default: VFFonts.fontMediumDefault),
    fontSemibold: font("fontSemibold", default: VFFonts.fontSemiboldDefault),
    fontBold: font("fontBold", default: VFFonts.fontBoldDefault)
  )
}
#endif
