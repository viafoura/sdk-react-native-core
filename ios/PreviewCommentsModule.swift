import ExpoModulesCore
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

class RNPreviewComments: ExpoView, VFLoginDelegate, VFLayoutDelegate, VFAdDelegate, VFCustomUIDelegate {
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
    vc.setCustomUIDelegate(customUIDelegate: self)
    if !authorId.isEmpty { vc.setAuthorsIds(authors: [authorId]) }
    vc.setAdDelegate(adDelegate: self)

    parentVC.addChild(vc)
    addSubview(vc.view)
    vc.view.frame = bounds
    vc.didMove(toParent: parentVC)
    vc.setTheme(theme: resolveTheme())
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
    profileVC.setCustomUIDelegate(customUIDelegate: self)
    profileVC.setTheme(theme: resolveTheme())
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
    newCommentVC.setCustomUIDelegate(customUIDelegate: self)
    newCommentVC.setTheme(theme: resolveTheme())
    parentVC.present(newCommentVC, animated: true)
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    onAction(event)
  }

  // VFCustomUIDelegate
  func customizeView(theme: VFTheme, view: VFCustomizableView) {
    let resolved = resolveCustomView(view)
    let themeKey = (theme == .dark) ? "dark" : "light"
    guard let style = CustomUIViewRegistry.shared.style(viewType: resolved.type, theme: themeKey) else {
      return
    }
    CustomUIViewRegistry.shared.applyStyle(view: resolved.view, style: style)
  }

  private func resolveCustomView(_ customView: VFCustomizableView) -> (type: String, view: UIView) {
    switch customView {
    case .postButton(let button):
      return ("postButton", button)
    case .postTextView(let textField):
      return ("postTextView", textField)
    case .postCloseImage(let image):
      return ("postCloseImage", image)
    case .postUserImage(let image):
      return ("postUserImage", image)
    case .postUserAvatar(let avatar):
      return ("postUserAvatar", avatar)
    case .postMetadataTitle(let label):
      return ("postMetadataTitle", label)
    case .postMetadataImage(let image):
      return ("postMetadataImage", image)
    case .postMetadataDescription(let label):
      return ("postMetadataDescription", label)
    case .postHeaderDescription(let label):
      return ("postHeaderDescription", label)
    case .postPlaceholderLabel(let label):
      return ("postPlaceholderLabel", label)
    case .postImageSkeletonView(let skeletonView):
      return ("postImageSkeletonView", skeletonView)
    case .postTitleSkeletonView(let skeletonView):
      return ("postTitleSkeletonView", skeletonView)
    case .postDescriptionSkeletonView(let skeletonView):
      return ("postDescriptionSkeletonView", skeletonView)
    case .postBackgroundView(let view):
      return ("postBackgroundView", view)
    case .profileNameLabel(let label):
      return ("profileNameLabel", label)
    case .profileLogoutLabel(let label):
      return ("profileLogoutLabel", label)
    case .profileCloseImage(let image):
      return ("profileCloseImage", image)
    case .profileLikesLabel(let label):
      return ("profileLikesLabel", label)
    case .profileFollowersLabel(let label):
      return ("profileFollowersLabel", label)
    case .profileSegmentedControl(let segmentedControl):
      return ("profileSegmentedControl", segmentedControl)
    case .profileCommunityTabView(let tabView):
      return ("profileCommunityTabView", tabView)
    case .profileFollowView(let view):
      return ("profileFollowView", view)
    case .profileBackgroundView(let view):
      return ("profileBackgroundView", view)
    case .commentCellExpandRepliesLoading(let loadingView):
      return ("commentCellExpandRepliesLoading", loadingView)
    case .commentCellExpandRepliesImage(let image):
      return ("commentCellExpandRepliesImage", image)
    case .commentCellExpandRepliesLabel(let label):
      return ("commentCellExpandRepliesLabel", label)
    case .commentCellDateLabel(let label):
      return ("commentCellDateLabel", label)
    case .commentCellNameLabel(let label):
      return ("commentCellNameLabel", label)
    case .commentCellContentLabel(let label):
      return ("commentCellContentLabel", label)
    case .commentCellOptionsButton(let button):
      return ("commentCellOptionsButton", button)
    case .commentCellLikeImage(let image):
      return ("commentCellLikeImage", image)
    case .commentCellLikeLabel(let label):
      return ("commentCellLikeLabel", label)
    case .commentCellDislikeImage(let image):
      return ("commentCellDislikeImage", image)
    case .commentCellTrustedView(let view):
      return ("commentCellTrustedView", view)
    case .commentCellModeratorView(let view):
      return ("commentCellModeratorView", view)
    case .commentCellAuthorView(let view):
      return ("commentCellAuthorView", view)
    case .commentCellFollowView(let view):
      return ("commentCellFollowView", view)
    case .commentCellDislikeLabel(let label):
      return ("commentCellDislikeLabel", label)
    case .commentCellReplyLabel(let label):
      return ("commentCellReplyLabel", label)
    case .commentCellReplyImage(let image):
      return ("commentCellReplyImage", image)
    case .commentCellUserImage(let image):
      return ("commentCellUserImage", image)
    case .commentCellUserAvatar(let view):
      return ("commentCellUserAvatar", view)
    case .commentCellUserIndicator(let image):
      return ("commentCellUserIndicator", image)
    case .commentCellAwaitingModerationView(let view):
      return ("commentCellAwaitingModerationView", view)
    case .commentCellCustomBadge(let badge):
      return ("commentCellCustomBadge", badge)
    case .commentCellPinnedView(let view):
      return ("commentCellPinnedView", view)
    case .commentCellEditorPickView(let view):
      return ("commentCellEditorPickView", view)
    case .commentCellSeparator(let separator):
      return ("commentCellSeparator", separator)
    case .userCommentDescLabel(let label):
      return ("userCommentDescLabel", label)
    case .userCommentOriginalImage(let image):
      return ("userCommentOriginalImage", image)
    case .userCommentOriginalTitle(let label):
      return ("userCommentOriginalTitle", label)
    case .userCommentContentLabel(let label):
      return ("userCommentContentLabel", label)
    case .userCommentSeparator(let separator):
      return ("userCommentSeparator", separator)
    case .userCommentDateLabel(let label):
      return ("userCommentDateLabel", label)
    case .userCellImage(let image):
      return ("userCellImage", image)
    case .userCellAvatarView(let view):
      return ("userCellAvatarView", view)
    case .userCellNameLabel(let label):
      return ("userCellNameLabel", label)
    case .userCellActionDateLabel(let label):
      return ("userCellActionDateLabel", label)
    case .userCellBadgeLabel(let label):
      return ("userCellBadgeLabel", label)
    case .userCellBadgeView(let view):
      return ("userCellBadgeView", view)
    case .userCellSeparator(let separator):
      return ("userCellSeparator", separator)
    case .userCellFollowView(let view):
      return ("userCellFollowView", view)
    case .previewEmptyCommentsView(let emptyCommentsView):
      return ("previewEmptyCommentsView", emptyCommentsView)
    case .previewSeeMoreCommentsButton(let button):
      return ("previewSeeMoreCommentsButton", button)
    case .previewTitleLabel(let label):
      return ("previewTitleLabel", label)
    case .previewPrivacyLabel(let label):
      return ("previewPrivacyLabel", label)
    case .previewUserPromptLabel(let label):
      return ("previewUserPromptLabel", label)
    case .previewLoginLabel(let label):
      return ("previewLoginLabel", label)
    case .previewAuthOrLabel(let label):
      return ("previewAuthOrLabel", label)
    case .previewSignupLabel(let label):
      return ("previewSignupLabel", label)
    case .previewUserImage(let image):
      return ("previewUserImage", image)
    case .previewUserAvatar(let avatar):
      return ("previewUserAvatar", avatar)
    case .previewUserSomeoneWritingLabel(let label):
      return ("previewUserSomeoneWritingLabel", label)
    case .previewNewCommentsNotificationView(let view):
      return ("previewNewCommentsNotificationView", view)
    case .previewCommentPrompt(let view):
      return ("previewCommentPrompt", view)
    case .previewNotificationBellView(let view):
      return ("previewNotificationBellView", view)
    case .previewHeaderView(let view):
      return ("previewHeaderView", view)
    case .previewSortImage(let image):
      return ("previewSortImage", image)
    case .previewSortLabel(let label):
      return ("previewSortLabel", label)
    case .previewAllComments(let view):
      return ("previewAllComments", view)
    case .previewPoweredByView(let poweredByView):
      return ("previewPoweredByView", poweredByView)
    case .previewSkeletonView(let skeletonView):
      return ("previewSkeletonView", skeletonView)
    case .previewFollowView(let followView):
      return ("previewFollowView", followView)
    case .previewBackgroundView(let view):
      return ("previewBackgroundView", view)
    case .reportReasonOptionLabel(let label):
      return ("reportReasonOptionLabel", label)
    case .reportTitleLabel(let label):
      return ("reportTitleLabel", label)
    case .reportPickReasonLabel(let label):
      return ("reportPickReasonLabel", label)
    case .reportStartCloseLabel(let label):
      return ("reportStartCloseLabel", label)
    case .reportStartDescriptionLabel(let label):
      return ("reportStartDescriptionLabel", label)
    case .reportStartButton(let button):
      return ("reportStartButton", button)
    case .reportChosenTitleLabel(let label):
      return ("reportChosenTitleLabel", label)
    case .reportChosenDescriptionLabel(let label):
      return ("reportChosenDescriptionLabel", label)
    case .reportChosenCloseLabel(let label):
      return ("reportChosenCloseLabel", label)
    case .reportChosenButton(let button):
      return ("reportChosenButton", button)
    case .reportThanksLabel(let label):
      return ("reportThanksLabel", label)
    case .reportThanksButton(let button):
      return ("reportThanksButton", button)
    case .trendingVerticalBackgroundView(let view):
      return ("trendingVerticalBackgroundView", view)
    case .trendingVerticalTitleLabel(let label):
      return ("trendingVerticalTitleLabel", label)
    case .trendingVerticalFullImage(let image):
      return ("trendingVerticalFullImage", image)
    case .trendingVerticalFullImageIcon(let image):
      return ("trendingVerticalFullImageIcon", image)
    case .trendingVerticalFullTitle(let label):
      return ("trendingVerticalFullTitle", label)
    case .trendingVerticalFullCount(let label):
      return ("trendingVerticalFullCount", label)
    case .trendingVerticalViewMoreButton(let button):
      return ("trendingVerticalViewMoreButton", button)
    case .trendingVerticalCondensedTitle(let label):
      return ("trendingVerticalCondensedTitle", label)
    case .trendingVerticalCondensedCount(let label):
      return ("trendingVerticalCondensedCount", label)
    case .trendingCarouselTitle(let label):
      return ("trendingCarouselTitle", label)
    case .trendingCarouselImage(let image):
      return ("trendingCarouselImage", image)
    case .trendingCarouselCount(let label):
      return ("trendingCarouselCount", label)
    case .trendingCarouselBackgroundView(let view):
      return ("trendingCarouselBackgroundView", view)
    case .bottomPickerView(let view):
      return ("bottomPickerView", view)
    case .bottomPickerTitle(let label):
      return ("bottomPickerTitle", label)
    case .bottomPickerTitleLabel(let label):
      return ("bottomPickerTitleLabel", label)
    case .bottomPickerLabel(let label):
      return ("bottomPickerLabel", label)
    case .bottomPickerSeparator(let separatorView):
      return ("bottomPickerSeparator", separatorView)
    case .chatCellContentLabel(let label):
      return ("chatCellContentLabel", label)
    case .chatCellDateLabel(let label):
      return ("chatCellDateLabel", label)
    case .chatCellUserNameLabel(let label):
      return ("chatCellUserNameLabel", label)
    case .chatPostView(let view):
      return ("chatPostView", view)
    case .chatPostImage(let image):
      return ("chatPostImage", image)
    case .chatPostLoading(let loadingView):
      return ("chatPostLoading", loadingView)
    case .chatTextView(let textView):
      return ("chatTextView", textView)
    case .chatBackgroundView(let backgroundView):
      return ("chatBackgroundView", backgroundView)
    case .chatLoading(let loadingView):
      return ("chatLoading", loadingView)
    case .chatLoadingMore(let loadingView):
      return ("chatLoadingMore", loadingView)
    case .chatEmptyView(let emptyView):
      return ("chatEmptyView", emptyView)
    case .notificationContentImage(let image):
      return ("notificationContentImage", image)
    case .notificationRemoveImage(let image):
      return ("notificationRemoveImage", image)
    case .notificationTrendingCountImage(let image):
      return ("notificationTrendingCountImage", image)
    case .notificationTrendingImage(let image):
      return ("notificationTrendingImage", image)
    case .notificationTrendingIcon(let image):
      return ("notificationTrendingIcon", image)
    case .notificationGroupTitleLabel(let label):
      return ("notificationGroupTitleLabel", label)
    case .notificationBellText(let label):
      return ("notificationBellText", label)
    case .notificationBellIcon(let icon):
      return ("notificationBellIcon", icon)
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
      Events(
        "onHeightChanged",
        "onAuthNeeded",
        "onOpenProfile",
        "onNewComment",
        "onArticlePressed",
        "onAction"
      )
    }
  }
}
