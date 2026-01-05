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
  var darkMode: Bool = false

  // Events
  let onHeightChanged = EventDispatcher()
  let onAuthNeeded = EventDispatcher()
  let onOpenProfile = EventDispatcher()
  let onNewComment = EventDispatcher()
  let onArticlePressed = EventDispatcher()

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
      colorPrimary: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00),
      colorPrimaryLight: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00)
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
        self.presentNewCommentViewController(actionType: actionType)
      case .trendingArticlePressed(let metadata, let containerId):
        self.onArticlePressed(["containerId": containerId, "articleUrl": metadata.url.absoluteString])
      case .openProfilePressed(let userUUID, let presentationType):
        // Emit event and present profile for parity with Android
        self.onOpenProfile(["userUUID": userUUID.uuidString, "presentationType": String(describing: presentationType)])
        self.presentProfileViewController(userUUID: userUUID, presentationType: presentationType)
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
        self.onArticlePressed(["containerId": containerId, "articleUrl": metadata.url.absoluteString])
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
      case .commentPosted:
        self.onNewComment([:])
      default: break
      }
    }
    newCommentVC.setActionCallbacks(callbacks: callbacks)
    newCommentVC.setTheme(theme: darkMode ? .dark : .light)
    parentVC.present(newCommentVC, animated: true)
  }

  // MARK: VFLayoutDelegate
  func containerHeightUpdated(viewController: VFUIViewController, height: CGFloat) {
    onHeightChanged(["newHeight": height, "containerId": containerId])
  }

  // MARK: VFLoginDelegate
  func startLogin() {
    onAuthNeeded(["requireLogin": true])
  }

  // MARK: VFAdDelegate
  func getAdInterval(viewController: VFUIViewController) -> Int { 5 }
  func generateAd(viewController: VFUIViewController, adPosition: Int) -> VFAdView? { VFAdView() }
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

      // Events
      Events("onHeightChanged", "onAuthNeeded", "onOpenProfile", "onNewComment", "onArticlePressed")
    }
  }
}
