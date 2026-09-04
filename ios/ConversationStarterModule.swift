import ExpoModulesCore
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

class RNConversationStarter: ExpoView, VFLoginDelegate, VFLayoutDelegate, VFCustomUIDelegate {
  // Props
  var containerId: String = ""
  var articleUrl: String = ""
  var articleTitle: String = ""
  var articleSubtitle: String = ""
  var articleThumbnailUrl: String = ""
  var syndicationKey: String = ""
  var starterTitle: String = ""
  var starterDescription: String = ""
  var minimumCommentCount: Int? = nil
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
  let onSeeMoreComments = EventDispatcher()
  let onAction = EventDispatcher()

  // Internals
  private let fontBold = UIFont.boldSystemFont(ofSize: 17)
  private weak var conversationStarterViewController: VFConversationStarterViewController?
  private var settings: VFSettings?
  private var articleMetadata: VFArticleMetadata?

  override func layoutSubviews() {
    super.layoutSubviews()
    if conversationStarterViewController == nil {
      initializeSettings()
      embed()
    } else {
      conversationStarterViewController?.view.frame = bounds
    }
  }

  private func initializeSettings() {
    let colors = VFColors(
      colorPrimary: resolveColor(key: "colorPrimary", fallbackKey: "primary", fallback: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00)),
      colorPrimaryLight: resolveColor(key: "colorPrimaryLight", fallbackKey: "primaryLight", fallback: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00)),
      colorAvatars: resolveAvatarColors() ?? Constants.AvatarColors.colors
    )
    let fonts = VFFonts(fontBold: fontBold)
    settings = VFSettings(colors: colors, fonts: fonts)

    guard let url = URL(string: articleUrl), let thumb = URL(string: articleThumbnailUrl) else {
      return
    }
    articleMetadata = VFArticleMetadata(url: url, title: articleTitle, subtitle: articleSubtitle, thumbnailUrl: thumb)
  }

  private func embed() {
    guard let parentVC = parentViewController, let settings, let articleMetadata else { return }

    let vc = VFConversationStarterViewController.new(
      containerId: containerId,
      articleMetadata: articleMetadata,
      loginDelegate: self,
      settings: settings,
      title: starterTitle.isEmpty ? nil : starterTitle,
      description: starterDescription.isEmpty ? nil : starterDescription,
      minimumCommentCount: minimumCommentCount ?? VFConversationStarterDefaults.minimumCommentCount,
      syndicationKey: syndicationKey.isEmpty ? nil : syndicationKey
    )

    vc.setTheme(theme: resolveTheme())
    vc.loadViewIfNeeded()

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .seeMoreCommentsPressed:
        self.emitAction(type: "seeMoreCommentsPressed")
        self.onSeeMoreComments([String: Any]())
      case .writeNewCommentPressed(let actionType):
        self.emitAction(type: "writeNewCommentPressed", payload: ["actionType": self.stringForActionType(actionType)])
        self.onNewComment(["actionType": self.stringForActionType(actionType)])
        self.presentNewCommentViewController(actionType: actionType)
      case .openProfilePressed(let userUUID, let presentationType):
        let presentation = self.stringForPresentationType(presentationType)
        self.emitAction(type: "openProfilePressed", payload: ["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.onOpenProfile(["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
      case .commentLiked(let contentUUID):
        self.emitAction(type: "commentLiked", payload: ["content": contentUUID.uuidString])
      case .commentDisliked(let contentUUID):
        self.emitAction(type: "commentDisliked", payload: ["content": contentUUID.uuidString])
      case .authPressed:
        self.emitAction(type: "authPressed", payload: ["requireLogin": true])
        self.onAuthNeeded(["requireLogin": true])
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
    self.conversationStarterViewController = vc
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
      case .replyPosted(let contentUUID):
        self.emitAction(type: "replyPosted", payload: ["content": contentUUID.uuidString])
        self.conversationStarterViewController?.reload()
      default:
        break
      }
    }

    newCommentVC.setTheme(theme: resolveTheme())
    newCommentVC.loadViewIfNeeded()
    newCommentVC.setActionCallbacks(callbacks: callbacks)
    newCommentVC.setCustomUIDelegate(customUIDelegate: self)
    parentVC.present(newCommentVC, animated: true)
  }

  private func presentProfileViewController(userUUID: UUID, presentationType: VFProfilePresentationType) {
    guard let parentVC = parentViewController, let settings else { return }

    let profileVC = VFProfileViewController.new(
      userUUID: userUUID,
      presentationType: presentationType,
      loginDelegate: self,
      settings: settings
    )

    profileVC.setTheme(theme: resolveTheme())
    profileVC.loadViewIfNeeded()
    profileVC.setCustomUIDelegate(customUIDelegate: self)
    parentVC.present(profileVC, animated: true)
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    onAction(event)
  }

  // MARK: VFCustomUIDelegate
  func customizeView(theme: VFTheme, view: VFCustomizableView) {
    guard let resolved = resolveCustomView(view) else { return }
    let themeKey = (theme == .dark) ? "dark" : "light"
    guard let style = CustomUIViewRegistry.shared.style(viewType: resolved.type, theme: themeKey) else {
      return
    }
    CustomUIViewRegistry.shared.applyStyle(view: resolved.view, style: style)
  }

  private func resolveCustomView(_ customView: VFCustomizableView) -> (type: String, view: UIView)? {
    switch customView {
    case .conversationStarterBackgroundView(let view):
      return ("conversationStarterBackgroundView", view)
    case .conversationStarterHeaderLabel(let label):
      return ("conversationStarterHeaderLabel", label)
    case .conversationStarterTitleLabel(let label):
      return ("conversationStarterTitleLabel", label)
    case .conversationStarterDescriptionLabel(let label):
      return ("conversationStarterDescriptionLabel", label)
    case .conversationStarterFeaturedCommentLabel(let label):
      return ("conversationStarterFeaturedCommentLabel", label)
    case .conversationStarterActionButton(let button):
      return ("conversationStarterActionButton", button)
    default:
      return nil
    }
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
    conversationStarterViewController?.setTheme(theme: resolveTheme())
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
}

#else

class RNConversationStarter: ExpoView {}

#endif

public class ConversationStarterModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ConversationStarter")

    View(RNConversationStarter.self) {
      // Props
      Prop("containerId") { (view: RNConversationStarter, v: String) in view.containerId = v }
      Prop("articleUrl") { (view: RNConversationStarter, v: String) in view.articleUrl = v }
      Prop("articleTitle") { (view: RNConversationStarter, v: String) in view.articleTitle = v }
      Prop("articleSubtitle") { (view: RNConversationStarter, v: String?) in view.articleSubtitle = v ?? "" }
      Prop("articleThumbnailUrl") { (view: RNConversationStarter, v: String) in view.articleThumbnailUrl = v }
      Prop("syndicationKey") { (view: RNConversationStarter, v: String?) in view.syndicationKey = v ?? "" }
      Prop("title") { (view: RNConversationStarter, v: String?) in view.starterTitle = v ?? "" }
      Prop("description") { (view: RNConversationStarter, v: String?) in view.starterDescription = v ?? "" }
      Prop("minimumCommentCount") { (view: RNConversationStarter, v: Int?) in view.minimumCommentCount = v }
      Prop("darkMode") { (view: RNConversationStarter, v: Bool?) in view.darkMode = v ?? false }
      Prop("theme") { (view: RNConversationStarter, v: String?) in view.theme = v }
      Prop("colors") { (view: RNConversationStarter, v: [String: Any]?) in view.colors = v ?? [:] }

      // Events
      Events(
        "onHeightChanged",
        "onAuthNeeded",
        "onOpenProfile",
        "onNewComment",
        "onSeeMoreComments",
        "onAction"
      )
    }
  }
}
