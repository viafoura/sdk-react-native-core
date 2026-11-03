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
  root: UIViewController?,
  presentMember: @escaping (UUID, UIViewController) -> Void,
  emit: @escaping (String, [String: Any]) -> Void,
  onArticlePressed: @escaping ([String: Any]) -> Void = { _ in }
) -> VFActionsCallbacks {
  return { [weak profileVC, weak root] type in
    guard let profileVC else { return }
    switch type {
    case .trendingArticlePressed(let metadata, let containerId):
      let payload = trendingPayload(metadata: metadata, containerId: containerId)
      dismissPresentedStack(from: root ?? profileVC.presentingViewController) {
        emit("trendingArticlePressed", payload)
        onArticlePressed(payload)
      }
    case .notificationPressed(let presentation):
      let payload = notificationPayload(presentation)
      if case .profile(let userUUID) = presentation {
        presentMember(userUUID, profileVC)
        emit("notificationPressed", payload)
      } else {
        dismissPresentedStack(from: root ?? profileVC.presentingViewController) {
          emit("notificationPressed", payload)
        }
      }
    default:
      break
    }
  }
}

private func dismissPresentedStack(from presenter: UIViewController?, completion: @escaping () -> Void) {
  guard let presenter, presenter.presentedViewController != nil else {
    completion()
    return
  }
  presenter.dismiss(animated: true, completion: completion)
}

#endif
