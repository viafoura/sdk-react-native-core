import React
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

class RNLiveQuestions: UIView, VFLoginDelegate, VFLayoutDelegate, VFCustomUIDelegate {
  // Props
  @objc var containerId: String = ""
  @objc var articleUrl: String = ""
  @objc var articleTitle: String = ""
  @objc var articleSubtitle: String = ""
  @objc var articleThumbnailUrl: String = ""
  @objc var liveQuestionsTitle: String = ""
  @objc var sectionUUID: String = ""
  @objc var focusedContentUUID: String = ""
  @objc var limit: NSNumber?
  @objc var replyLimit: NSNumber?
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

  // Events
  @objc var onHeightChanged: RCTDirectEventBlock?
  @objc var onAuthNeeded: RCTDirectEventBlock?
  @objc var onOpenProfile: RCTDirectEventBlock?
  @objc var onAction: RCTDirectEventBlock?

  // Internals
  private weak var liveQuestionsViewController: VFLiveQuestionsViewController?
  private var settings: VFSettings?
  private var articleMetadata: VFArticleMetadata?

  override func layoutSubviews() {
    super.layoutSubviews()
    if liveQuestionsViewController == nil {
      initializeSettings()
      embed()
    } else {
      liveQuestionsViewController?.view.frame = bounds
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

    let resolvedTitle = liveQuestionsTitle.isEmpty ? nil : liveQuestionsTitle
    let resolvedFocused = focusedContentUUID.isEmpty ? nil : UUID(uuidString: focusedContentUUID)
    let resolvedLimit = limit?.intValue ?? 10
    let resolvedReplyLimit = replyLimit?.intValue ?? 2

    let vc: VFLiveQuestionsViewController
    if !sectionUUID.isEmpty, let section = UUID(uuidString: sectionUUID) {
      vc = VFLiveQuestionsViewController.new(
        containerId: containerId,
        articleMetadata: articleMetadata,
        loginDelegate: self,
        settings: settings,
        sectionUUID: section,
        limit: resolvedLimit,
        replyLimit: resolvedReplyLimit,
        title: resolvedTitle,
        focusedContentUUID: resolvedFocused
      )
    } else {
      vc = VFLiveQuestionsViewController.new(
        containerId: containerId,
        articleMetadata: articleMetadata,
        loginDelegate: self,
        settings: settings,
        limit: resolvedLimit,
        replyLimit: resolvedReplyLimit,
        title: resolvedTitle,
        focusedContentUUID: resolvedFocused
      )
    }

    vc.setTheme(theme: resolveTheme())
    vc.loadViewIfNeeded()

    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .openProfilePressed(let userUUID, let presentationType):
        let presentation = self.stringForPresentationType(presentationType)
        self.emitAction(type: "openProfilePressed", payload: ["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.onOpenProfile?(["userUUID": userUUID.uuidString, "presentationType": presentation])
        self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
      case .authPressed:
        self.emitAction(type: "authPressed", payload: ["requireLogin": true])
        self.onAuthNeeded?(["requireLogin": true])
      case .writeNewQuestionPressed(let actionType):
        self.emitAction(type: "writeNewQuestionPressed", payload: self.payloadForQuestionAction(actionType))
        self.presentComposerViewController(actionType: actionType)
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
    self.liveQuestionsViewController = vc
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

  private func presentComposerViewController(actionType: VFNewQuestionActionType) {
    guard let parentVC = parentViewController, let settings, let articleMetadata else { return }

    let section = sectionUUID.isEmpty ? nil : UUID(uuidString: sectionUUID)
    let composerVC = VFLiveQuestionsComposerViewController.new(
      newQuestionActionType: actionType,
      containerId: containerId,
      articleMetadata: articleMetadata,
      loginDelegate: self,
      settings: settings,
      sectionUUID: section
    )
    let callbacks: VFActionsCallbacks = { [weak self] type in
      guard let self else { return }
      switch type {
      case .commentPosted(let contentUUID):
        self.emitAction(type: "commentPosted", payload: ["content": contentUUID.uuidString])
      case .replyPosted(let contentUUID):
        self.emitAction(type: "replyPosted", payload: ["content": contentUUID.uuidString])
      case .authPressed:
        self.emitAction(type: "authPressed", payload: ["requireLogin": true])
        self.onAuthNeeded?(["requireLogin": true])
      default:
        break
      }
    }
    composerVC.setTheme(theme: resolveTheme())
    composerVC.loadViewIfNeeded()
    composerVC.setActionCallbacks(callbacks: callbacks)
    parentVC.present(UINavigationController(rootViewController: composerVC), animated: true)
  }

  private func payloadForQuestionAction(_ actionType: VFNewQuestionActionType) -> [String: Any] {
    switch actionType {
    case .question:
      return ["actionType": "question"]
    case .reply(let content):
      return ["actionType": "reply", "content": content.uuidString]
    case .answer(let content):
      return ["actionType": "answer", "content": content.uuidString]
    }
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    onAction?(event)
  }

  // MARK: VFCustomUIDelegate
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
    liveQuestionsViewController?.setTheme(theme: resolveTheme())
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
}

#else

class RNLiveQuestions: UIView {}

#endif
