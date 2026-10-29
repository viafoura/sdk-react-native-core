import React
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

class RNNotificationBell: UIView, VFLoginDelegate, VFCustomUIDelegate {
  @objc var darkMode: Bool = false {
    didSet {
      applyThemeIfReady()
    }
  }
  @objc var theme: String? = nil {
    didSet {
      applyThemeIfReady()
    }
  }
  @objc var colors: [String: Any] = [:]
  @objc var fonts: [String: Any] = [:]
  @objc var profileStyle: String? = nil
  @objc var elevationEnabled: Bool = false {
    didSet {
      bellView?.isElevationEnabled = elevationEnabled
    }
  }
  @objc var backgroundColorEnabled: Bool = true {
    didSet {
      bellView?.isBackgroundColorEnabled = backgroundColorEnabled
    }
  }

  @objc(onViafouraBellPressed) var onBellPressed: RCTDirectEventBlock?
  @objc(onViafouraAuthNeeded) var onAuthNeeded: RCTDirectEventBlock?
  @objc(onViafouraAction) var onAction: RCTDirectEventBlock?

  private var bellView: VFNotificationBellView?
  private var settings: VFSettings?

  override func layoutSubviews() {
    super.layoutSubviews()
    if bellView == nil {
      initializeSettings()
      embed()
    } else {
      bellView?.frame = bounds
    }
  }

  private func initializeSettings() {
    let colors = VFColors(
      colorPrimary: resolveColor(key: "colorPrimary", fallbackKey: "primary", fallback: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00)),
      colorPrimaryLight: resolveColor(key: "colorPrimaryLight", fallbackKey: "primaryLight", fallback: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00)),
      colorAvatars: resolveAvatarColors() ?? Constants.AvatarColors.colors
    )
    settings = VFSettings(colors: colors, fonts: resolveVFFonts(fonts))
  }

  private func embed() {
    guard let settings else { return }

    let bell = VFNotificationBellView(settings: settings, loginDelegate: self, onBellClicked: { [weak self] userUUID in
      guard let self else { return }
      self.emitAction(type: "bellPressed", payload: ["userUUID": userUUID.uuidString])
      self.onBellPressed?(["userUUID": userUUID.uuidString])
      self.presentProfileViewController(userUUID: userUUID)
    })
    bell.isElevationEnabled = elevationEnabled
    bell.isBackgroundColorEnabled = backgroundColorEnabled
    bell.setTheme(theme: resolveTheme())
    bell.setCustomUIDelegate(customUIDelegate: self)

    addSubview(bell)
    bell.frame = bounds
    bellView = bell
  }

  private func presentProfileViewController(userUUID: UUID) {
    guard let parentVC = parentViewController, let settings else { return }
    let profileVC = VFProfileViewController.new(
      userUUID: userUUID,
      presentationType: .profile,
      loginDelegate: self,
      settings: settings,
      style: resolveProfileStyle()
    )

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .trendingArticlePressed(let metadata, let containerId):
        profileVC.dismiss(animated: true)
        self.emitAction(type: "trendingArticlePressed", payload: ["containerId": containerId, "articleUrl": metadata.url.absoluteString])
      case .notificationPressed(let presentation):
        var payload: [String: Any] = [:]
        switch presentation {
        case .profile(let userUUID):
          payload["presentationType"] = "profile"
          payload["userUUID"] = userUUID.uuidString
        case .content(let containerUUID, let contentUUID, let containerId, let articleMetadata):
          payload["presentationType"] = "content"
          payload["containerUUID"] = containerUUID.uuidString
          payload["contentUUID"] = contentUUID.uuidString
          payload["containerId"] = containerId
          payload["articleUrl"] = articleMetadata.url.absoluteString
        @unknown default:
          break
        }
        self.emitAction(type: "notificationPressed", payload: payload)
      default:
        break
      }
    }
    profileVC.setTheme(theme: resolveTheme())
    profileVC.loadViewIfNeeded()
    profileVC.setActionCallbacks(callbacks: callbacks)
    profileVC.setCustomUIDelegate(customUIDelegate: self)
    parentVC.present(profileVC, animated: true)
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    onAction?(event)
  }

  func customizeView(theme: VFTheme, view: VFCustomizableView) {
    guard let resolved = resolveCustomizableView(view) else { return }
    let themeKey = (theme == .dark) ? "dark" : "light"
    guard let style = CustomUIViewRegistry.shared.style(viewType: resolved.type, theme: themeKey) else {
      return
    }
    CustomUIViewRegistry.shared.applyStyle(view: resolved.view, style: style)
  }

  private func resolveTheme() -> VFTheme {
    switch theme?.lowercased() {
    case "dark":
      return .dark
    case "light":
      return .light
    default:
      return darkMode ? .dark : .light
    }
  }

  private func resolveProfileStyle() -> VFProfileStyle {
    profileStyle?.lowercased() == "drawer" ? .drawer : .default
  }

  private func applyThemeIfReady() {
    bellView?.setTheme(theme: resolveTheme())
  }

  private func resolveColor(key: String, fallbackKey: String, fallback: UIColor) -> UIColor {
    let hex = (colors[key] as? String) ?? (colors[fallbackKey] as? String)
    if let hex, let parsed = UIColor.vfColor(fromHex: hex) {
      return parsed
    }
    return fallback
  }

  private func resolveAvatarColors() -> [UIColor]? {
    let raw = colors["colorAvatars"] ?? colors["avatars"]
    let list: [String]? = (raw as? [String]) ?? (raw as? [Any])?.compactMap { $0 as? String }
    guard let list, list.count == Constants.AvatarColors.colors.count else {
      return nil
    }
    var parsed: [UIColor] = []
    parsed.reserveCapacity(list.count)
    for hex in list {
      guard let color = UIColor.vfColor(fromHex: hex) else { return nil }
      parsed.append(color)
    }
    return parsed
  }

  func startLogin() {
    emitAction(type: "authPressed", payload: ["requireLogin": true])
    onAuthNeeded?(["requireLogin": true])
  }
}

#else

class RNNotificationBell: UIView {}

#endif
