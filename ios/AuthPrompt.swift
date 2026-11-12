import Foundation

#if canImport(ViafouraSDK)
import ViafouraSDK

final class AuthPromptTracker {
  private var pendingPromptType: String?

  func promptReceived(_ promptType: VFAuthPromptType) {
    pendingPromptType = stringForAuthPromptType(promptType)
  }

  func loginRequested() -> [String: Any] {
    var payload: [String: Any] = ["requireLogin": true]
    if let pendingPromptType {
      payload["promptType"] = pendingPromptType
    }
    pendingPromptType = nil
    return payload
  }
}

func stringForAuthPromptType(_ promptType: VFAuthPromptType) -> String {
  switch promptType {
  case .like:
    return "like"
  case .dislike:
    return "dislike"
  case .header:
    return "header"
  case .postContent:
    return "postContent"
  case .followConversation:
    return "followConversation"
  case .followUser:
    return "followUser"
  case .muteUser:
    return "muteUser"
  case .flag:
    return "flag"
  case .bellPressed:
    return "bellPressed"
  case .standaloneBellPressed:
    return "standaloneBellPressed"
  @unknown default:
    return "unknown"
  }
}
#endif
