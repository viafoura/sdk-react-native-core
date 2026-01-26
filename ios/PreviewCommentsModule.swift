import ExpoModulesCore
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

class RNPreviewComments: ExpoView, VFLoginDelegate, VFLayoutDelegate, VFAdDelegate {
  // Props
  var containerId: String = ""
  var authorId: String = ""
  var articleUrl: String = ""
  var articleTitle: String = ""
  var syndicationKey: String = ""
  var articleSubtitle: String = ""
  var articleThumbnailUrl: String = ""
  var darkMode: Bool = false {
    didSet {
      applyThemeIfReady()
    }
  }
  var theme: String? = nil {
    didSet {
      applyThemeIfReady()
    }
  }
  var colors: [String: Any] = [:]

  // Events
  let onHeightChanged = EventDispatcher()
  let onAuthNeeded = EventDispatcher()
  let onOpenProfile = EventDispatcher()
  let onNewComment = EventDispatcher()
  let onArticlePressed = EventDispatcher()
  let onAction = EventDispatcher()

  // Internals
  let fontBold = UIFont.boldSystemFont(ofSize: 17)
  weak var previewCommentsViewController: VFPreviewCommentsViewController?
  var settings: VFSettings?
  var articleMetadata: VFArticleMetadata?

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
    let resolvedTheme = resolveTheme()
    var colors = VFColors(
      colorPrimary: resolveColor(key: "colorPrimary", fallbackKey: "primary", fallback: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00)),
      colorPrimaryLight: resolveColor(key: "colorPrimaryLight", fallbackKey: "primaryLight", fallback: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00)),
      colorAvatars: resolveAvatarColors() ?? Constants.AvatarColors.colors
    )
    colors.setTheme(theme: resolvedTheme)
    let fonts = VFFonts(fontBold: fontBold)
    settings = VFSettings(colors: colors, fonts: fonts)

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

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .writeNewCommentPressed(let actionType):
        self.emitAction(type: "writeNewCommentPressed", payload: ["actionType": self.stringForActionType(actionType)])
        self.presentNewCommentViewController(actionType: actionType)
      case .trendingArticlePressed(let metadata, let containerId):
        self.emitAction(type: "trendingArticlePressed", payload: ["containerId": containerId, "articleUrl": metadata.url.absoluteString])
        self.onArticlePressed(["containerId": containerId, "articleUrl": metadata.url.absoluteString])
      case .openProfilePressed(let userUUID, let presentationType):
        // Emit event and present profile for parity with Android
        let presentation = self.stringForPresentationType(presentationType)
        self.emitAction(type: "openProfilePressed", payload: ["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.onOpenProfile(["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
      case .seeMoreCommentsPressed:
        self.emitAction(type: "seeMoreCommentsPressed")
      default:
        break
      }
    }

    vc.setActionCallbacks(callbacks: callbacks)
    vc.setLayoutDelegate(layoutDelegate: self)
    if !authorId.isEmpty { vc.setAuthorsIds(authors: [authorId]) }
    vc.setAdDelegate(adDelegate: self)

    parentVC.addChild(vc)
    addSubview(vc.view)
    vc.view.frame = bounds
    vc.didMove(toParent: parentVC)
    vc.setTheme(theme: darkMode ? .dark : .light)
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
        self.onArticlePressed(["containerId": containerId, "articleUrl": metadata.url.absoluteString])
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
        }
        self.emitAction(type: "notificationPressed", payload: payload)
      default: break
      }
    }
    profileVC.setActionCallbacks(callbacks: callbacks)
    profileVC.setTheme(theme: darkMode ? .dark : .light)
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
        self.onNewComment(["content": contentUUID.uuidString])
      case .replyPosted(let contentUUID):
        self.emitAction(type: "replyPosted", payload: ["content": contentUUID.uuidString])
      default: break
      }
    }
    newCommentVC.setActionCallbacks(callbacks: callbacks)
    newCommentVC.setTheme(theme: darkMode ? .dark : .light)
    parentVC.present(newCommentVC, animated: true)
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    onAction(event)
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
    onHeightChanged(["newHeight": height, "containerId": containerId])
  }

  // MARK: VFLoginDelegate
  func startLogin() {
    emitAction(type: "authPressed", payload: ["requireLogin": true])
    onAuthNeeded(["requireLogin": true])
  }

  // MARK: VFAdDelegate
  func getAdInterval(viewController: VFUIViewController) -> Int { 5 }
  func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView? { VFAdView() }
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

class RNPreviewComments: ExpoView {}

#endif

public class PreviewCommentsModule: Module {
  public func definition() -> ModuleDefinition {
    Name("PreviewComments")

    View(RNPreviewComments.self) {
      // Props
      Prop("containerId") { (view: RNPreviewComments, v: String) in view.containerId = v }
      Prop("authorId") { (view: RNPreviewComments, v: String?) in view.authorId = v ?? "" }
      Prop("articleUrl") { (view: RNPreviewComments, v: String) in view.articleUrl = v }
      Prop("articleTitle") { (view: RNPreviewComments, v: String) in view.articleTitle = v }
      Prop("articleSubtitle") { (view: RNPreviewComments, v: String?) in view.articleSubtitle = v ?? "" }
      Prop("articleThumbnailUrl") { (view: RNPreviewComments, v: String) in view.articleThumbnailUrl = v }
      Prop("syndicationKey") { (view: RNPreviewComments, v: String?) in view.syndicationKey = v ?? "" }
      Prop("darkMode") { (view: RNPreviewComments, v: Bool?) in view.darkMode = v ?? false }
      Prop("theme") { (view: RNPreviewComments, v: String?) in view.theme = v }
      Prop("colors") { (view: RNPreviewComments, v: [String: Any]?) in view.colors = v ?? [:] }

      // Events
      Events("onHeightChanged", "onAuthNeeded", "onOpenProfile", "onNewComment", "onArticlePressed", "onAction")
    }
  }
}
