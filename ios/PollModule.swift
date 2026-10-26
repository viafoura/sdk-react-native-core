import React
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

class RNPoll: UIView, VFLoginDelegate, VFLayoutDelegate, VFCustomUIDelegate {
  @objc var containerId: String = ""
  @objc var contentContainerUUID: String = ""
  @objc var sectionUUID: String = ""
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

  @objc(onViafouraHeightChanged) var onHeightChanged: RCTDirectEventBlock?
  @objc(onViafouraAuthNeeded) var onAuthNeeded: RCTDirectEventBlock?
  @objc(onViafouraAction) var onAction: RCTDirectEventBlock?

  private weak var pollViewController: VFPollViewController?
  private var settings: VFSettings?

  override func layoutSubviews() {
    super.layoutSubviews()
    if pollViewController == nil {
      initializeSettings()
      embed()
    } else {
      pollViewController?.view.frame = bounds
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
    guard let parentVC = parentViewController, let settings else { return }

    let section = sectionUUID.isEmpty ? nil : UUID(uuidString: sectionUUID)
    let vc: VFPollViewController
    if let contentContainer = UUID(uuidString: contentContainerUUID) {
      vc = VFPollViewController.new(contentContainerUUID: contentContainer, loginDelegate: self, settings: settings)
    } else if !containerId.isEmpty {
      vc = VFPollViewController.new(containerId: containerId, loginDelegate: self, settings: settings, sectionUUID: section)
    } else {
      return
    }

    vc.setTheme(theme: resolveTheme())
    vc.loadViewIfNeeded()

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .authPressed:
        self.emitAction(type: "authPressed", payload: ["requireLogin": true])
        self.onAuthNeeded?(["requireLogin": true])
      default:
        break
      }
    }

    vc.setActionCallbacks(callbacks: callbacks)
    vc.setLayoutDelegate(layoutDelegate: self)
    vc.setCustomUIDelegate(customUIDelegate: self)

    parentVC.addChild(vc)
    addSubview(vc.view)
    vc.view.frame = bounds
    vc.didMove(toParent: parentVC)
    self.pollViewController = vc
  }

  override func removeFromSuperview() {
    detachEmbeddedViewController()
    super.removeFromSuperview()
  }

  deinit {
    detachEmbeddedViewController()
  }

  private func detachEmbeddedViewController() {
    guard let vc = pollViewController else { return }
    vc.willMove(toParent: nil)
    vc.view.removeFromSuperview()
    vc.removeFromParent()
    pollViewController = nil
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

  private func applyThemeIfReady() {
    pollViewController?.setTheme(theme: resolveTheme())
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

  func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
    onHeightChanged?(["newHeight": height, "containerId": containerId.isEmpty ? contentContainerUUID : containerId])
  }

  func startLogin() {
    emitAction(type: "authPressed", payload: ["requireLogin": true])
    onAuthNeeded?(["requireLogin": true])
  }
}

#else

class RNPoll: UIView {}

#endif
