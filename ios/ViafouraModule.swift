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
  case invalidUUID(String)
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
    case .invalidUUID(let value):
      return "Invalid UUID: \(value)"
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

  var siteUUID: UUID? {
    Self.initLock.lock()
    defer { Self.initLock.unlock() }
    return Self.siteUUID
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

// ViafouraSDK 1.3.20 declares the fields of its notification, follower and profile-stats
// responses (and most of CommentResponse) internal, so they are read by reflection. The
// labels are the API's JSON keys; once the SDK makes the fields public this can go.
struct VFReflectedFields {
  private var values: [String: Any] = [:]

  init(_ subject: Any) {
    for child in Mirror(reflecting: subject).children {
      if let label = child.label {
        values[label] = Self.unwrap(child.value)
      }
    }
  }

  private static func unwrap(_ value: Any) -> Any? {
    let mirror = Mirror(reflecting: value)
    guard mirror.displayStyle == .optional else { return value }
    return mirror.children.first.flatMap { unwrap($0.value) }
  }

  func string(_ key: String) -> String? {
    guard let value = values[key] else { return nil }
    switch value {
    case let string as String: return string
    case let uuid as UUID: return uuid.uuidString
    default: return String(describing: value)
    }
  }

  func number(_ key: String) -> Double {
    switch values[key] {
    case let value as Int: return Double(value)
    case let value as Int64: return Double(value)
    case let value as Int32: return Double(value)
    case let value as Double: return value
    default: return 0
    }
  }

  func bool(_ key: String) -> Bool {
    values[key] as? Bool ?? false
  }

  func list(_ key: String) -> [Any] {
    values[key] as? [Any] ?? []
  }
}

struct VFCommunityAdapter {
  private var service: VFNotificationsService { ViafouraSDK.notifications() }

  func newNotificationCount(completion: @escaping (Result<Int, Error>) -> Void) {
    Task { completion(await service.getNewNotificationCount()) }
  }

  func allNotifications(completion: @escaping (Result<[String: Any], Error>) -> Void) {
    Task {
      completion(await service.getUserNotifications().map { response -> [String: Any] in
        let fields = VFReflectedFields(response)
        let notifications: [[String: Any]] = fields.list("notifications").map { notification -> [String: Any] in
          let n = VFReflectedFields(notification)
          return [
            "groupingKey": n.number("grouping_key"),
            "type": n.string("notification_type") ?? "unknown",
            "serviceType": n.string("service_type") ?? "unknown",
            "targetUUID": n.string("target_uuid") ?? "",
            "threadUUID": n.string("thread_uuid") ?? "",
            "contentContainerUUID": n.string("content_container_uuid") ?? "",
            "sectionUUID": n.string("section_uuid") ?? "",
            "events": n.list("notifications").map { payload -> [String: Any] in
              let p = VFReflectedFields(payload)
              return [
                "notificationUUID": p.string("notification_uuid") ?? "",
                "actorUUID": p.string("actor_uuid") ?? "",
                "actorType": p.string("actor_type") ?? "",
                "contentUUID": p.string("content_uuid") ?? "",
                "status": p.string("status") ?? "new",
                "time": p.number("time"),
              ]
            },
          ]
        }
        let broadcasts: [[String: Any]] = fields.list("broadcasts").map { broadcast -> [String: Any] in
          let b = VFReflectedFields(broadcast)
          var map: [String: Any] = [
            "notificationUUID": b.string("notification_uuid") ?? "",
            "sectionUUID": b.string("section_uuid") ?? "",
            "actorUUID": b.string("actor_uuid") ?? "",
            "type": b.string("notification_type") ?? "unknown",
            "status": b.string("status") ?? "new",
            "time": b.number("time"),
            "title": b.string("target_title") ?? "",
            "description": b.string("target_description") ?? "",
            "url": b.string("target_url") ?? "",
            "topicId": b.string("target_topic_id") ?? "",
          ]
          if let imageUrl = b.string("target_image_url") { map["imageUrl"] = imageUrl }
          return map
        }
        return ["notifications": notifications, "broadcasts": broadcasts]
      })
    }
  }

  func markNotificationsRead(_ uuids: [UUID], completion: @escaping (Result<Void, Error>) -> Void) {
    Task { completion(await service.markNotificationsRead(notifications: uuids).map { _ in () }) }
  }

  func markNotificationsSeen(_ uuids: [UUID], completion: @escaping (Result<Void, Error>) -> Void) {
    Task { completion(await service.markNotificationsSeen(notifications: uuids).map { _ in () }) }
  }

  func removeNotifications(_ uuids: [UUID], completion: @escaping (Result<Void, Error>) -> Void) {
    Task { completion(await service.removeNotifications(notifications: uuids).map { _ in () }) }
  }

  func followers(page: Int?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    Task { completion(await service.getUserSubscribers(pageNumber: page).map { Self.followPage($0) }) }
  }

  func following(page: Int?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    Task { completion(await service.getUserSubscriptions(pageNumber: page).map { Self.followPage($0) }) }
  }

  private static func followPage(_ response: Any) -> [String: Any] {
    let fields = VFReflectedFields(response)
    return [
      "total": fields.number("total"),
      "hasMore": fields.bool("hasMore"),
      "users": fields.list("subscriptions").map { subscription -> [String: Any] in
        let s = VFReflectedFields(subscription)
        return [
          "userUUID": s.string("user_uuid") ?? "",
          "subscriptionUUID": s.string("subscription_uuid") ?? "",
          "dateCreated": s.number("date_created"),
        ]
      },
    ]
  }

  func followerCount(userUUID: UUID, completion: @escaping (Result<Int, Error>) -> Void) {
    Task { completion(await service.getSubscribersCount(userUUID: userUUID)) }
  }

  func isFollowing(userUUID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) {
    Task { completion(await service.isSubscribedToUser(userUUID: userUUID)) }
  }

  func follow(userUUID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
    Task { completion(await service.subscribeToUser(userUUID: userUUID).map { _ in () }) }
  }

  func unfollow(userUUID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
    Task { completion(await service.unsubscribeFromUser(userUUID: userUUID).map { _ in () }) }
  }

  func userInfo(userUUID: UUID, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    Task {
      completion(await ViafouraSDK.users().getUserInfo(userUUID: userUUID)
        .mapError { $0 as Error }
        .map { user -> [String: Any] in
          var map: [String: Any] = ["userUUID": userUUID.uuidString, "name": user.name]
          if let large = user.pic_large { map["avatarUrl"] = large }
          if let small = user.pic_small { map["avatarSmallUrl"] = small }
          return map
        })
    }
  }

  func userComments(siteUUID: UUID, userUUID: UUID, limit: Int, startingFrom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    Task {
      let result = await ViafouraSDK.comments().getUserCommentsPage(
        sectionUUID: siteUUID,
        userUUID: userUUID,
        limit: limit,
        startingFrom: startingFrom
      )
      completion(result.mapError { $0 as Error }.map { response -> [String: Any] in
        let comments: [[String: Any]] = response.contents.map { comment -> [String: Any] in
          let c = VFReflectedFields(comment)
          return [
            "contentUUID": c.string("content_uuid") ?? "",
            "contentContainerUUID": c.string("content_container_uuid") ?? "",
            "threadUUID": c.string("thread_uuid") ?? "",
            "content": comment.content,
            "dateCreated": Double(comment.date_created),
            "totalLikes": c.number("total_likes"),
            "totalReplies": c.number("total_replies"),
          ]
        }
        var page: [String: Any] = [
          "comments": comments,
          "moreAvailable": VFReflectedFields(response).bool("more_available"),
        ]
        if let last = response.contents.last, let cursor = VFReflectedFields(last).string("content_uuid") {
          page["nextCursor"] = cursor
        }
        return page
      })
    }
  }

  func userStats(siteUUID: UUID, userUUID: UUID, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    Task {
      let result = await ViafouraSDK.comments().getCommentsProfile(sectionUUID: siteUUID, userUUID: userUUID)
      completion(result.mapError { $0 as Error }.map { response -> [String: Any] in
        let fields = VFReflectedFields(response)
        return [
          "contentCreated": fields.number("content_created"),
          "likesReceived": fields.number("likes_received"),
          "likesCreated": fields.number("likes_created"),
          "dislikesReceived": fields.number("dislikes_received"),
          "dislikesCreated": fields.number("dislikes_created"),
        ]
      })
    }
  }
}

#else

enum VFAdapterError: Error, LocalizedError {
  case sdkUnavailable
  case invalidProvider
  case invalidInitialization
  case alreadyInitializedWithDifferentSite
  case invalidContainerId
  case invalidUUID(String)
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
    case .invalidUUID(let value):
      return "Invalid UUID: \(value)"
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

  var siteUUID: UUID? { nil }

  func commentCount(containerId: String, syndicationKey: String?, completion: @escaping (Result<Int, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func trendingArticles(limit: Int, trendWindow: Int, daysPublished: Int?, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }
}

struct VFCommunityAdapter {
  func newNotificationCount(completion: @escaping (Result<Int, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func allNotifications(completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func markNotificationsRead(_ uuids: [UUID], completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func markNotificationsSeen(_ uuids: [UUID], completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func removeNotifications(_ uuids: [UUID], completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func followers(page: Int?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func following(page: Int?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func followerCount(userUUID: UUID, completion: @escaping (Result<Int, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func isFollowing(userUUID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func follow(userUUID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func unfollow(userUUID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func userInfo(userUUID: UUID, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func userComments(siteUUID: UUID, userUUID: UUID, limit: Int, startingFrom: String?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func userStats(siteUUID: UUID, userUUID: UUID, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }
}

#endif


@objc(Viafoura)
public class ViafouraModule: NSObject {
  private let auth = VFAuthAdapter()
  private let core = VFCoreAdapter()
  private let community = VFCommunityAdapter()

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

  private func settle<T>(
    _ result: Result<T, Error>,
    _ resolve: @escaping RCTPromiseResolveBlock,
    _ reject: @escaping RCTPromiseRejectBlock
  ) {
    switch result {
    case .success(let value):
      resolve(value)
    case .failure(let error):
      reject("ERR_VIAFOURA", error.localizedDescription, error)
    }
  }

  private func parseUUID(_ value: String?, _ reject: RCTPromiseRejectBlock) -> UUID? {
    if let value, let uuid = UUID(uuidString: value.trimmingCharacters(in: .whitespacesAndNewlines)) {
      return uuid
    }
    let error = VFAdapterError.invalidUUID(value ?? "")
    reject("ERR_VIAFOURA", error.localizedDescription, error)
    return nil
  }

  private func parseUUIDs(_ values: [String], _ reject: RCTPromiseRejectBlock) -> [UUID]? {
    var uuids: [UUID] = []
    for value in values {
      guard let uuid = parseUUID(value, reject) else { return nil }
      uuids.append(uuid)
    }
    return uuids
  }

  private func requireSiteUUID(_ reject: RCTPromiseRejectBlock) -> UUID? {
    if let siteUUID = core.siteUUID { return siteUUID }
    let error = VFAdapterError.notInitialized
    reject("ERR_VIAFOURA", error.localizedDescription, error)
    return nil
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

  @objc(getNewNotificationCount:rejecter:)
  public func getNewNotificationCount(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    community.newNotificationCount { self.settle($0, resolve, reject) }
  }

  @objc(getNotifications:rejecter:)
  public func getNotifications(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    community.allNotifications { self.settle($0, resolve, reject) }
  }

  @objc(markNotificationsRead:resolver:rejecter:)
  public func markNotificationsRead(
    _ notificationUUIDs: [String],
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuids = parseUUIDs(notificationUUIDs, reject) else { return }
    community.markNotificationsRead(uuids) { self.settle($0, resolve, reject) }
  }

  @objc(markNotificationsSeen:resolver:rejecter:)
  public func markNotificationsSeen(
    _ notificationUUIDs: [String],
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuids = parseUUIDs(notificationUUIDs, reject) else { return }
    community.markNotificationsSeen(uuids) { self.settle($0, resolve, reject) }
  }

  @objc(removeNotifications:resolver:rejecter:)
  public func removeNotifications(
    _ notificationUUIDs: [String],
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuids = parseUUIDs(notificationUUIDs, reject) else { return }
    community.removeNotifications(uuids) { self.settle($0, resolve, reject) }
  }

  @objc(getFollowers:resolver:rejecter:)
  public func getFollowers(
    _ page: NSNumber?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    community.followers(page: page?.intValue) { self.settle($0, resolve, reject) }
  }

  @objc(getFollowing:resolver:rejecter:)
  public func getFollowing(
    _ page: NSNumber?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    community.following(page: page?.intValue) { self.settle($0, resolve, reject) }
  }

  @objc(getFollowerCount:resolver:rejecter:)
  public func getFollowerCount(
    _ userUUID: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject) else { return }
    community.followerCount(userUUID: uuid) { self.settle($0, resolve, reject) }
  }

  @objc(isFollowingUser:resolver:rejecter:)
  public func isFollowingUser(
    _ userUUID: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject) else { return }
    community.isFollowing(userUUID: uuid) { self.settle($0, resolve, reject) }
  }

  @objc(followUser:resolver:rejecter:)
  public func followUser(
    _ userUUID: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject) else { return }
    community.follow(userUUID: uuid) { self.settle($0, resolve, reject) }
  }

  @objc(unfollowUser:resolver:rejecter:)
  public func unfollowUser(
    _ userUUID: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject) else { return }
    community.unfollow(userUUID: uuid) { self.settle($0, resolve, reject) }
  }

  @objc(getUserInfo:resolver:rejecter:)
  public func getUserInfo(
    _ userUUID: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject) else { return }
    community.userInfo(userUUID: uuid) { self.settle($0, resolve, reject) }
  }

  @objc(getUserComments:limit:startingFrom:resolver:rejecter:)
  public func getUserComments(
    _ userUUID: String,
    limit: NSNumber,
    startingFrom: String?,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject), let siteUUID = requireSiteUUID(reject) else { return }
    community.userComments(
      siteUUID: siteUUID,
      userUUID: uuid,
      limit: limit.intValue,
      startingFrom: startingFrom
    ) { self.settle($0, resolve, reject) }
  }

  @objc(getUserStats:resolver:rejecter:)
  public func getUserStats(
    _ userUUID: String,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let uuid = parseUUID(userUUID, reject), let siteUUID = requireSiteUUID(reject) else { return }
    community.userStats(siteUUID: siteUUID, userUUID: uuid) { self.settle($0, resolve, reject) }
  }
}
