import Foundation
import React

// Optional Viafoura SDK import. Code is guarded to build without it.
#if canImport(ViafouraSDK)
import ViafouraSDK

enum VFAdapterError: Error, LocalizedError {
  case invalidProvider
  case invalidInitialization
  case alreadyInitializedWithDifferentSite
  case invalidContainerId
  case notInitialized

  var errorDescription: String? {
    switch self {
    case .invalidProvider:
      return "Invalid social login provider"
    case .invalidInitialization:
      return "Invalid Viafoura initialization parameters"
    case .alreadyInitializedWithDifferentSite:
      return "ViafouraSDK is already initialized with a different site"
    case .invalidContainerId:
      return "Invalid Viafoura container id"
    case .notInitialized:
      return "ViafouraSDK is not initialized"
    }
  }
}

struct VFAuthAdapter {
  private let authService = ViafouraSDK.auth()

  func logout() {
    authService.logout()
  }

  func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.login(email: email, password: password) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func signup(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.signup(name: name, email: email, password: password, recaptchaToken: nil) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func socialLogin(token: String, provider: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let p = VFSocialLoginProvider(rawValue: provider) else {
      completion(.failure(VFAdapterError.invalidProvider))
      return
    }
    authService.socialLogin(token: token, provider: p) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func loginRadiusLogin(token: String, provider: String?, completion: @escaping (Result<Void, Error>) -> Void) {
    let p: VFSocialLoginProvider
    if let provider, !provider.isEmpty {
      guard let parsed = VFSocialLoginProvider(rawValue: provider) else {
        completion(.failure(VFAdapterError.invalidProvider))
        return
      }
      p = parsed
    } else {
      p = .none
    }

    authService.loginRadiusLogin(token: token, provider: p) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func openIdLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.openIdLogin(token: token) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func cookieLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.cookieLogin(token: token) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.resetPassword(email: email) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getUserLoginStatus(completion: @escaping ([String: Any]) -> Void) {
    authService.getUserLoginStatus { result in
      switch result {
      case .success(.loggedIn(let userUUID)):
        completion(["isLoggedIn": true, "userUUID": userUUID.uuidString])
      case .success(.notLoggedIn):
        completion(["isLoggedIn": false])
      }
    }
  }
}

struct VFCoreAdapter {
  private static let initLock = NSLock()
  private static var initializedKey: String?
  private static var siteUUID: UUID?

  func initialize(siteUUID: String, siteDomain: String, enableLogging: Bool) throws {
    guard let key = Self.initializationKey(siteUUID: siteUUID, siteDomain: siteDomain) else {
      throw VFAdapterError.invalidInitialization
    }

    Self.initLock.lock()
    defer { Self.initLock.unlock() }

    if let initializedKey = Self.initializedKey {
      guard initializedKey == key else {
        throw VFAdapterError.alreadyInitializedWithDifferentSite
      }
      ViafouraSDK.setLoggingEnabled(enableLogging)
      return
    }

    ViafouraSDK.setLoggingEnabled(enableLogging)
    ViafouraSDK.initialize(siteUUID: siteUUID, siteDomain: siteDomain)
    Self.initializedKey = key
    Self.siteUUID = UUID(uuidString: siteUUID.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  func setDataTrackingEnabled(_ enabled: Bool) {
    ViafouraSDK.setDataTrackingEnabled(enabled)
  }

  func commentCount(containerId: String, syndicationKey: String?, completion: @escaping (Result<Int, Error>) -> Void) {
    ViafouraSDK.comments().commentCount(sectionUUID: nil, containerId: containerId, syndicationKey: syndicationKey) { result in
      switch result {
      case .success(let count):
        completion(.success(count))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func trendingArticles(limit: Int, trendWindow: Int, daysPublished: Int?, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
    Self.initLock.lock()
    let siteUUID = Self.siteUUID
    Self.initLock.unlock()
    guard let siteUUID else {
      completion(.failure(VFAdapterError.notInitialized))
      return
    }
    Task {
      let result = await ViafouraSDK.comments().trendingComments(
        sectionUUID: siteUUID,
        limit: limit,
        contentContainerWindowDays: daysPublished,
        contentContainerWindowHours: trendWindow,
        sortedBy: .comments
      )
      switch result {
      case .success(let articles):
        completion(.success(articles.map { article in
          var map: [String: Any] = [
            "containerId": article.container_id,
            "contentContainerUUID": article.content_container_uuid,
            "title": article.origin_title,
            "url": article.origin_url,
            "commentCount": article.total_visible_contents,
            "datePublished": article.date_published,
          ]
          if let summary = article.origin_summary { map["summary"] = summary }
          if let imageUrl = article.origin_image_url { map["imageUrl"] = imageUrl }
          return map
        }))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private static func initializationKey(siteUUID: String, siteDomain: String) -> String? {
    let trimmedSiteUUID = siteUUID.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedSiteDomain = siteDomain.trimmingCharacters(in: .whitespacesAndNewlines)

    guard
      let uuid = UUID(uuidString: trimmedSiteUUID),
      !trimmedSiteDomain.isEmpty
    else {
      return nil
    }

    return "\(uuid.uuidString.lowercased())::\(normalizeSiteDomain(trimmedSiteDomain))"
  }

  private static func normalizeSiteDomain(_ value: String) -> String {
    if let url = URL(string: value), let host = url.host, !host.isEmpty {
      return host.lowercased()
    }

    return value.lowercased()
  }
}

#else

enum VFAdapterError: Error, LocalizedError {
  case sdkUnavailable
  case invalidProvider
  case invalidInitialization
  case alreadyInitializedWithDifferentSite
  case invalidContainerId
  case notInitialized

  var errorDescription: String? {
    switch self {
    case .sdkUnavailable:
      return "ViafouraSDK is not installed. Add the iOS SDK to enable auth."
    case .invalidProvider:
      return "Invalid social login provider"
    case .invalidInitialization:
      return "Invalid Viafoura initialization parameters"
    case .alreadyInitializedWithDifferentSite:
      return "ViafouraSDK is already initialized with a different site"
    case .invalidContainerId:
      return "Invalid Viafoura container id"
    case .notInitialized:
      return "ViafouraSDK is not initialized"
    }
  }
}

struct VFAuthAdapter {
  func logout() { /* no-op when SDK unavailable */ }

  func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func signup(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func socialLogin(token: String, provider: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func loginRadiusLogin(token: String, provider: String?, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func openIdLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func cookieLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func getUserLoginStatus(completion: @escaping ([String: Any]) -> Void) {
    completion(["isLoggedIn": false])
  }
}

struct VFCoreAdapter {
  func initialize(siteUUID: String, siteDomain: String, enableLogging: Bool) throws {
    // no-op
  }

  func setDataTrackingEnabled(_ enabled: Bool) {
    // no-op
  }

  func commentCount(containerId: String, syndicationKey: String?, completion: @escaping (Result<Int, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func trendingArticles(limit: Int, trendWindow: Int, daysPublished: Int?, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }
}

#endif


@objc(Viafoura)
public class ViafouraModule: NSObject {
  private let auth = VFAuthAdapter()
  private let core = VFCoreAdapter()

  @objc
  public static func requiresMainQueueSetup() -> Bool {
    return false
  }

  private func settle(
    _ result: Result<Void, Error>,
    _ resolve: @escaping RCTPromiseResolveBlock,
    _ reject: @escaping RCTPromiseRejectBlock
  ) {
    switch result {
    case .success:
      resolve(nil)
    case .failure(let error):
      reject("ERR_VIAFOURA", error.localizedDescription, error)
    }
  }

  @objc(logout:rejecter:)
  public func logout(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.logout()
    resolve(nil)
  }

  @objc(login:password:resolver:rejecter:)
  public func login(
    _ email: String,
    password: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.login(email: email, password: password) { self.settle($0, resolve, reject) }
  }

  @objc(signup:email:password:resolver:rejecter:)
  public func signup(
    _ name: String,
    email: String,
    password: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.signup(name: name, email: email, password: password) { self.settle($0, resolve, reject) }
  }

  @objc(socialLogin:provider:resolver:rejecter:)
  public func socialLogin(
    _ token: String,
    provider: String?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let provider = provider, !provider.isEmpty else {
      let error = VFAdapterError.invalidProvider
      reject("ERR_VIAFOURA", error.localizedDescription, error)
      return
    }
    auth.socialLogin(token: token, provider: provider) { self.settle($0, resolve, reject) }
  }

  @objc(loginRadiusLogin:provider:resolver:rejecter:)
  public func loginRadiusLogin(
    _ token: String,
    provider: String?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.loginRadiusLogin(token: token, provider: provider) { self.settle($0, resolve, reject) }
  }

  @objc(openIdLogin:resolver:rejecter:)
  public func openIdLogin(
    _ token: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.openIdLogin(token: token) { self.settle($0, resolve, reject) }
  }

  @objc(cookieLogin:resolver:rejecter:)
  public func cookieLogin(
    _ token: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.cookieLogin(token: token) { self.settle($0, resolve, reject) }
  }

  @objc(resetPassword:resolver:rejecter:)
  public func resetPassword(
    _ email: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.resetPassword(email: email) { self.settle($0, resolve, reject) }
  }

  @objc(getUserLoginStatus:rejecter:)
  public func getUserLoginStatus(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    auth.getUserLoginStatus { resolve($0) }
  }

  @objc(initialize:siteDomain:enableLogging:resolver:rejecter:)
  public func initialize(
    _ siteUUID: String,
    siteDomain: String,
    enableLogging: Bool,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard !siteUUID.isEmpty, !siteDomain.isEmpty else {
      let error = VFAdapterError.invalidInitialization
      reject("ERR_VIAFOURA", error.localizedDescription, error)
      return
    }
    do {
      try core.initialize(
        siteUUID: siteUUID,
        siteDomain: siteDomain,
        enableLogging: enableLogging
      )
      resolve(nil)
    } catch {
      reject("ERR_VIAFOURA", error.localizedDescription, error)
    }
  }

  @objc(setDataTrackingEnabled:resolver:rejecter:)
  public func setDataTrackingEnabled(
    _ enabled: Bool,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    core.setDataTrackingEnabled(enabled)
    resolve(nil)
  }

  @objc(getCommentCount:syndicationKey:resolver:rejecter:)
  public func getCommentCount(
    _ containerId: String,
    syndicationKey: String?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard !containerId.isEmpty else {
      let error = VFAdapterError.invalidContainerId
      reject("ERR_VIAFOURA", error.localizedDescription, error)
      return
    }
    core.commentCount(containerId: containerId, syndicationKey: syndicationKey) { result in
      switch result {
      case .success(let count):
        resolve(count)
      case .failure(let error):
        reject("ERR_VIAFOURA", error.localizedDescription, error)
      }
    }
  }

  @objc(getTrendingArticles:trendWindow:daysPublished:resolver:rejecter:)
  public func getTrendingArticles(
    _ limit: NSNumber,
    trendWindow: NSNumber,
    daysPublished: NSNumber?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    core.trendingArticles(
      limit: limit.intValue,
      trendWindow: trendWindow.intValue,
      daysPublished: daysPublished?.intValue
    ) { result in
      switch result {
      case .success(let articles):
        resolve(articles)
      case .failure(let error):
        reject("ERR_VIAFOURA", error.localizedDescription, error)
      }
    }
  }
}
