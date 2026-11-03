import UIKit

#if canImport(ViafouraSDK)
import ViafouraSDK

func notificationPayload(_ presentation: VFNotificationPresentationType) -> [String: Any] {
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
    payload["articleTitle"] = articleMetadata.title
  case .liveQuestions(let containerUUID, let contentUUID, let containerId, let articleMetadata):
    payload["presentationType"] = "liveQuestions"
    payload["containerUUID"] = containerUUID.uuidString
    payload["contentUUID"] = contentUUID.uuidString
    payload["containerId"] = containerId
    payload["articleUrl"] = articleMetadata.url.absoluteString
    payload["articleTitle"] = articleMetadata.title
  case .url(let url):
    payload["presentationType"] = "url"
    payload["url"] = url.absoluteString
  @unknown default:
    break
  }
  return payload
}

func trendingPayload(metadata: VFArticleMetadata, containerId: String) -> [String: Any] {
  ["containerId": containerId, "articleUrl": metadata.url.absoluteString]
}

func profileCallbacks(
  for profileVC: VFProfileViewController,
  presentMember: @escaping (UUID, UIViewController) -> Void,
  emit: @escaping (String, [String: Any]) -> Void,
  onArticlePressed: @escaping ([String: Any]) -> Void = { _ in }
) -> VFActionsCallbacks {
  return { [weak profileVC] type in
    guard let profileVC else { return }
    switch type {
    case .trendingArticlePressed(let metadata, let containerId):
      profileVC.dismiss(animated: true)
      let payload = trendingPayload(metadata: metadata, containerId: containerId)
      emit("trendingArticlePressed", payload)
      onArticlePressed(payload)
    case .notificationPressed(let presentation):
      if case .profile(let userUUID) = presentation {
        presentMember(userUUID, profileVC)
      } else {
        profileVC.dismiss(animated: true)
      }
      emit("notificationPressed", notificationPayload(presentation))
    default:
      break
    }
  }
}

#endif
