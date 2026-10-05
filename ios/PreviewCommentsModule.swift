import React
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

final class AdSlotBinding {
  let adView = VFAdView()

  private(set) weak var slot: RNAdSlot?
  private var edgeConstraints: [NSLayoutConstraint] = []
  private var heightConstraint: NSLayoutConstraint?
  private var appliedHeight: CGFloat = -1

  func attach(slot: RNAdSlot) {
    if self.slot === slot, slot.superview === adView {
      updateHeight(slot.contentHeight)
      return
    }

    detach()

    slot.removeFromSuperview()
    slot.translatesAutoresizingMaskIntoConstraints = false
    adView.addSubview(slot)

    edgeConstraints = [
      slot.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
      slot.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
      slot.topAnchor.constraint(equalTo: adView.topAnchor),
      slot.bottomAnchor.constraint(equalTo: adView.bottomAnchor)
    ]
    NSLayoutConstraint.activate(edgeConstraints)

    let constraint = slot.heightAnchor.constraint(equalToConstant: 0)
    constraint.isActive = true
    heightConstraint = constraint
    self.slot = slot

    updateHeight(slot.contentHeight)
  }

  func detach() {
    NSLayoutConstraint.deactivate(edgeConstraints)
    edgeConstraints = []
    heightConstraint?.isActive = false
    heightConstraint = nil
    slot?.removeFromSuperview()
    slot = nil
    appliedHeight = -1
  }

  func updateHeight(_ height: CGFloat) {
    guard let heightConstraint, abs(height - appliedHeight) > 0.5 else { return }
    appliedHeight = height
    heightConstraint.constant = height
    adView.setNeedsLayout()
    DispatchQueue.main.async { @MainActor [adView] in
      adView.notifySizeChanged()
    }
  }
}

class RNPreviewComments: UIView, VFLoginDelegate, VFLayoutDelegate, VFAdDelegate, VFCustomUIDelegate {
  // Props
  @objc var containerId: String = ""
  @objc var authorId: String = ""
  @objc var articleUrl: String = ""
  @objc var articleTitle: String = ""
  @objc var syndicationKey: String = ""
  @objc var articleSubtitle: String = ""
  @objc var articleThumbnailUrl: String = ""
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
  @objc var adInterval: Int = 0
  @objc var firstAdPosition: Int = 2

  // Events
  @objc var onHeightChanged: RCTDirectEventBlock?
  @objc var onAuthNeeded: RCTDirectEventBlock?
  @objc var onOpenProfile: RCTDirectEventBlock?
  @objc var onNewComment: RCTDirectEventBlock?
  @objc var onArticlePressed: RCTDirectEventBlock?
  @objc var onAction: RCTDirectEventBlock?
  @objc var onAdSlotRequested: RCTDirectEventBlock?
  // Internals
  weak var previewCommentsViewController: VFPreviewCommentsViewController?
  var settings: VFSettings?
  var articleMetadata: VFArticleMetadata?
  private var adBindings: [Int: AdSlotBinding] = [:]
  private var adSlots: [Int: RNAdSlot] = [:]

  override func layoutSubviews() {
    super.layoutSubviews()
    if previewCommentsViewController == nil {
      initializeSettings()
      embed()
    } else {
      previewCommentsViewController?.view.frame = bounds
    }
  }

  private func initializeSettings() {
    let colors = VFColors(
      colorPrimary: resolveColor(key: "colorPrimary", fallbackKey: "primary", fallback: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00)),
      colorPrimaryLight: resolveColor(key: "colorPrimaryLight", fallbackKey: "primaryLight", fallback: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00)),
      colorAvatars: resolveAvatarColors() ?? Constants.AvatarColors.colors
    )
    settings = VFSettings(colors: colors, fonts: resolveVFFonts(fonts))

    guard let url = URL(string: articleUrl), let thumb = URL(string: articleThumbnailUrl) else {
      return
    }
    articleMetadata = VFArticleMetadata(url: url, title: articleTitle, subtitle: articleSubtitle, thumbnailUrl: thumb)
  }

  private func embed() {
    guard let parentVC = parentViewController, let settings, let articleMetadata else { return }

    let vc = VFPreviewCommentsViewController.new(
      containerId: containerId,
      articleMetadata: articleMetadata,
      loginDelegate: self,
      settings: settings,
      defaultSort: .newest,
      syndicationKey: syndicationKey.isEmpty ? nil : syndicationKey
    )

    vc.setTheme(theme: resolveTheme())
    vc.loadViewIfNeeded()

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .writeNewCommentPressed(let actionType):
        self.emitAction(type: "writeNewCommentPressed", payload: ["actionType": self.stringForActionType(actionType)])
        self.presentNewCommentViewController(actionType: actionType)
      case .trendingArticlePressed(let metadata, let containerId):
        self.emitAction(type: "trendingArticlePressed", payload: ["containerId": containerId, "articleUrl": metadata.url.absoluteString])
        self.onArticlePressed?(["containerId": containerId, "articleUrl": metadata.url.absoluteString])
      case .openProfilePressed(let userUUID, let presentationType):
        // Emit event and present profile for parity with Android
        let presentation = self.stringForPresentationType(presentationType)
        self.emitAction(type: "openProfilePressed", payload: ["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.onOpenProfile?(["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
      case .seeMoreCommentsPressed:
        self.emitAction(type: "seeMoreCommentsPressed")
      default:
        break
      }
    }

    vc.setActionCallbacks(callbacks: callbacks)
    vc.setLayoutDelegate(layoutDelegate: self)
    vc.setCustomUIDelegate(customUIDelegate: self)
    if !authorId.isEmpty { vc.setAuthorsIds(authors: [authorId]) }
    vc.setAdDelegate(adDelegate: self)

    parentVC.addChild(vc)
    addSubview(vc.view)
    vc.view.frame = bounds
    vc.didMove(toParent: parentVC)
    self.previewCommentsViewController = vc
  }

  private func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType) {
    guard let parentVC = parentViewController, let settings else { return }
    let profileVC = VFProfileViewController.new(
      userUUID: userUUID,
      presentationType: presentationType,
      loginDelegate: self,
      settings: settings
    )

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .trendingArticlePressed(let metadata, let containerId):
        profileVC.dismiss(animated: true)
        self.emitAction(type: "trendingArticlePressed", payload: ["containerId": containerId, "articleUrl": metadata.url.absoluteString])
        self.onArticlePressed?(["containerId": containerId, "articleUrl": metadata.url.absoluteString])
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
      default: break
      }
    }
    profileVC.setTheme(theme: resolveTheme())
    profileVC.loadViewIfNeeded()
    profileVC.setActionCallbacks(callbacks: callbacks)
    profileVC.setCustomUIDelegate(customUIDelegate: self)
    parentVC.present(profileVC, animated: true)
  }

  private func presentNewCommentViewController(actionType: VFNewCommentActionType) {
    guard let parentVC = parentViewController, let settings, let articleMetadata else { return }
    let newCommentVC = VFNewCommentViewController.new(
      newCommentActionType: actionType,
      containerId: containerId,
      articleMetadata: articleMetadata,
      loginDelegate: self,
      settings: settings,
      syndicationKey: syndicationKey.isEmpty ? nil : syndicationKey
    )
    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .commentPosted(let contentUUID):
        self.emitAction(type: "commentPosted", payload: ["content": contentUUID.uuidString])
        self.onNewComment?(["content": contentUUID.uuidString])
      case .replyPosted(let contentUUID):
        self.emitAction(type: "replyPosted", payload: ["content": contentUUID.uuidString])
      default: break
      }
    }
    newCommentVC.setTheme(theme: resolveTheme())
    newCommentVC.loadViewIfNeeded()
    newCommentVC.setActionCallbacks(callbacks: callbacks)
    newCommentVC.setCustomUIDelegate(customUIDelegate: self)
    parentVC.present(newCommentVC, animated: true)
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    onAction?(event)
  }

  // VFCustomUIDelegate
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
    previewCommentsViewController?.setTheme(theme: resolveTheme())
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

  private func stringForActionType(_ actionType: VFNewCommentActionType) -> String {
    switch actionType {
    case .create:
      return "create"
    case .edit:
      return "edit"
    case .reply:
      return "reply"
    @unknown default:
      return "create"
    }
  }

  private func stringForPresentationType(_ presentationType: VFProfilePresentationType) -> String {
    switch presentationType {
    case .profile:
      return "profile"
    case .feed:
      return "feed"
    @unknown default:
      return "profile"
    }
  }

  // MARK: VFLayoutDelegate
  func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
    onHeightChanged?(["newHeight": height, "containerId": containerId])
  }

  // MARK: VFLoginDelegate
  func startLogin() {
    emitAction(type: "authPressed", payload: ["requireLogin": true])
    onAuthNeeded?(["requireLogin": true])
  }

  // MARK: VFAdDelegate
  func getAdInterval(viewController: VFUIViewController) -> Int { adInterval }

  func getFirstAdPosition(viewController: VFUIViewController) -> Int { firstAdPosition }

  func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView? {
    guard adInterval > 0 else { return nil }

    if let existing = adBindings[adPosition] {
      return existing.adView
    }

    let binding = AdSlotBinding()
    adBindings[adPosition] = binding

    if let slot = adSlots[adPosition] {
      binding.attach(slot: slot)
    } else {
      onAdSlotRequested?(["position": adPosition, "containerId": containerId])
    }

    return binding.adView
  }

  // MARK: Ad slots
  private func registerAdSlot(_ slot: RNAdSlot) {
    adSlots[slot.position] = slot
    slot.onContentSizeChange = { [weak self, weak slot] in
      guard let slot, let binding = self?.adBindings[slot.position] else { return }
      binding.updateHeight(slot.contentHeight)
    }
    adBindings[slot.position]?.attach(slot: slot)
  }

  private func unregisterAdSlot(_ slot: RNAdSlot) {
    slot.onContentSizeChange = nil
    if adSlots[slot.position] === slot {
      adSlots.removeValue(forKey: slot.position)
    }
    if adBindings[slot.position]?.slot === slot {
      adBindings[slot.position]?.detach()
    }
    slot.removeFromSuperview()
  }

#if RCT_NEW_ARCH_ENABLED
  public override func mountChildComponentView(_ childComponentView: UIView, index: Int) {
    if let slot = childComponentView as? RNAdSlot {
      registerAdSlot(slot)
      return
    }
    super.mountChildComponentView(childComponentView, index: index)
  }

  public override func unmountChildComponentView(_ childComponentView: UIView, index: Int) {
    if let slot = childComponentView as? RNAdSlot {
      unregisterAdSlot(slot)
      return
    }
    super.unmountChildComponentView(childComponentView, index: index)
  }
#else
  override func didAddSubview(_ subview: UIView) {
    super.didAddSubview(subview)
    if let slot = subview as? RNAdSlot {
      registerAdSlot(slot)
    }
  }

  override func willRemoveSubview(_ subview: UIView) {
    super.willRemoveSubview(subview)
    if let slot = subview as? RNAdSlot {
      unregisterAdSlot(slot)
    }
  }
#endif
}

extension UIColor {
  static func vfColor(fromHex hex: String) -> UIColor? {
    var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if value.hasPrefix("#") {
      value.removeFirst()
    }
    if value.count == 6 {
      value = "FF" + value
    }
    guard value.count == 8, let hexNumber = UInt64(value, radix: 16) else {
      return nil
    }
    let alpha = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
    let red = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
    let green = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
    let blue = CGFloat(hexNumber & 0x000000FF) / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while let responder = parentResponder {
      parentResponder = responder.next
      if let vc = parentResponder as? UIViewController {
        return vc
      }
    }
    return nil
  }
}

#else

class RNPreviewComments: UIView {}

#endif
