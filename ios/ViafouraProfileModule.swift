import React
import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK
#endif

@objc(ViafouraProfile)
class ViafouraProfileModule: RCTEventEmitter {
  static let eventName = "ViafouraProfileEvent"

  private var hasListeners = false
  #if canImport(ViafouraSDK)
  private var sessions: [String: ProfileSheetSession] = [:]
  #endif

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }

  override func supportedEvents() -> [String]! {
    return [Self.eventName]
  }

  override func startObserving() {
    hasListeners = true
  }

  override func stopObserving() {
    hasListeners = false
  }

  @objc(presentProfile:options:resolver:rejecter:)
  func presentProfile(
    _ presentationId: String,
    options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    #if canImport(ViafouraSDK)
    let options = options as? [String: Any] ?? [:]
    let rawUUID = options["userUUID"] as? String ?? ""
    guard let userUUID = UUID(uuidString: rawUUID) else {
      reject("invalid_uuid", "Invalid UUID: \(rawUUID)", nil)
      return
    }
    let presentationType: VFProfilePresentationType =
      (options["presentationType"] as? String) == "feed" ? .feed : .profile

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard let presenter = RCTPresentedViewController() else {
        reject("no_presenter", "No view controller to present the profile from", nil)
        return
      }
      // UIKit drops a presentation started mid-transition without calling its completion,
      // which would leave the promise pending forever.
      if presenter.presentedViewController != nil || presenter.isBeingPresented || presenter.isBeingDismissed {
        reject("presentation_in_progress", "Another view controller is being presented or dismissed", nil)
        return
      }
      let session = ProfileSheetSession(
        options: options,
        emit: { [weak self] event, payload in
          self?.emit(presentationId: presentationId, event: event, payload: payload)
        },
        onFinish: { [weak self] in
          self?.sessions[presentationId] = nil
        }
      )
      self.sessions[presentationId] = session
      session.present(userUUID: userUUID, presentationType: presentationType, from: presenter) {
        resolve(nil)
      }
    }
    #else
    reject("not_linked", "ViafouraSDK is not available", nil)
    #endif
  }

  private func emit(presentationId: String, event: String, payload: [String: Any]?) {
    guard hasListeners else { return }
    var body: [String: Any] = ["presentationId": presentationId, "event": event]
    if let payload {
      body["payload"] = payload
    }
    sendEvent(withName: Self.eventName, body: body)
  }
}

#if canImport(ViafouraSDK)

final class ProfileSheetSession: NSObject, VFLoginDelegate, VFCustomUIDelegate {
  private let options: [String: Any]
  private let emit: (String, [String: Any]?) -> Void
  private let onFinish: () -> Void
  private let authPrompt = AuthPromptTracker()
  private lazy var settings = VFSettings(colors: resolveColors(), fonts: resolveVFFonts(options["fonts"] as? [String: Any] ?? [:]))
  private weak var root: UIViewController?
  private var sheetDismissed = false
  private var loginPending = false
  private var finished = false

  init(options: [String: Any], emit: @escaping (String, [String: Any]?) -> Void, onFinish: @escaping () -> Void) {
    self.options = options
    self.emit = emit
    self.onFinish = onFinish
  }

  func present(
    userUUID: UUID,
    presentationType: VFProfilePresentationType,
    from presenter: UIViewController,
    completion: (() -> Void)? = nil
  ) {
    let isRoot = root == nil
    if isRoot {
      root = presenter
    }

    let profileVC = VFProfileViewController.new(
      userUUID: userUUID,
      presentationType: presentationType,
      loginDelegate: self,
      settings: settings,
      style: (options["profileStyle"] as? String)?.lowercased() == "unity" ? .unity : .legacy
    )
    let callbacks = profileCallbacks(
      for: profileVC,
      root: root,
      presentMember: { [weak self] userUUID, presenter in
        self?.present(userUUID: userUUID, presentationType: .profile, from: presenter)
      },
      emit: { [weak self] type, payload in self?.emitAction(type: type, payload: payload) },
      onAuthPrompt: { [weak self] promptType in self?.authPrompt.promptReceived(promptType) }
    )
    profileVC.setTheme(theme: resolveTheme())
    profileVC.loadViewIfNeeded()
    profileVC.setActionCallbacks(callbacks: callbacks)
    profileVC.setCustomUIDelegate(customUIDelegate: self)

    if isRoot {
      let observer = DismissalObserver()
      observer.onDismiss = { [weak self] in self?.rootSheetDismissed() }
      profileVC.addChild(observer)
      profileVC.view.addSubview(observer.view)
      observer.didMove(toParent: profileVC)
    }

    presenter.present(profileVC, animated: true, completion: completion)
  }

  private func rootSheetDismissed() {
    sheetDismissed = true
    // Deferred so a login prompt the SDK raises from its own dismissal completion is
    // delivered before "close", while this session (the SDK's weak login delegate) lives.
    DispatchQueue.main.async { [weak self] in
      guard let self, !self.loginPending else { return }
      self.finish()
    }
  }

  private func finish() {
    guard !finished else { return }
    finished = true
    emit("close", nil)
    onFinish()
  }

  private func emitAction(type: String, payload: [String: Any] = [:]) {
    var event = payload
    event["type"] = type
    emit("action", event)
  }

  // MARK: VFLoginDelegate
  func startLogin() {
    let payload = authPrompt.loginRequested()
    loginPending = true
    // The host's login UI would otherwise open underneath the sheet. Captured strongly so
    // the session outlives the dismissal and still delivers the prompt.
    dismissPresentedStack(from: root) { [self] in
      emitAction(type: "authPressed", payload: payload)
      emit("authNeeded", payload)
      loginPending = false
      if sheetDismissed {
        finish()
      }
    }
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
    switch (options["theme"] as? String)?.lowercased() {
    case "dark":
      return .dark
    case "light":
      return .light
    default:
      return (options["darkMode"] as? Bool) == true ? .dark : .light
    }
  }

  private func resolveColors() -> VFColors {
    VFColors(
      colorPrimary: resolveColor(key: "colorPrimary", fallbackKey: "primary", fallback: UIColor(red: 0.00, green: 0.45, blue: 0.91, alpha: 1.00)),
      colorPrimaryLight: resolveColor(key: "colorPrimaryLight", fallbackKey: "primaryLight", fallback: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1.00)),
      colorAvatars: resolveAvatarColors() ?? Constants.AvatarColors.colors
    )
  }

  private func resolveColor(key: String, fallbackKey: String, fallback: UIColor) -> UIColor {
    let colors = options["colors"] as? [String: Any] ?? [:]
    let hex = (colors[key] as? String) ?? (colors[fallbackKey] as? String)
    if let hex, let parsed = UIColor.vfColor(fromHex: hex) {
      return parsed
    }
    return fallback
  }

  private func resolveAvatarColors() -> [UIColor]? {
    let colors = options["colors"] as? [String: Any] ?? [:]
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
}

/// The SDK dismisses the profile itself (close button, swipe down, logout, notification
/// taps), and VFProfileViewController exposes no dismissal callback, so an invisible child
/// controller reports when its parent sheet goes away.
private final class DismissalObserver: UIViewController {
  var onDismiss: (() -> Void)?

  override func loadView() {
    view = UIView(frame: .zero)
    view.isHidden = true
    view.isUserInteractionEnabled = false
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    guard let parent, parent.isBeingDismissed || parent.presentingViewController == nil else { return }
    fire()
  }

  // A sheet dismissed from further down the presentation stack may never get
  // appearance callbacks, but it is still released.
  deinit {
    let onDismiss = self.onDismiss
    DispatchQueue.main.async { onDismiss?() }
  }

  private func fire() {
    let onDismiss = self.onDismiss
    self.onDismiss = nil
    onDismiss?()
  }
}

#endif
