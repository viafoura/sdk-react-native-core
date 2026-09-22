import Foundation
import React
import UIKit

@objc(PreviewCommentsManager)
class PreviewCommentsManager: RCTViewManager {
  override func view() -> UIView! {
    return RNPreviewComments()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

@objc(ConversationStarterManager)
class ConversationStarterManager: RCTViewManager {
  override func view() -> UIView! {
    return RNConversationStarter()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

@objc(ViafouraAdSlotManager)
class ViafouraAdSlotManager: RCTViewManager {
  override func view() -> UIView! {
    return RNAdSlot()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

@objc(LiveQuestionsManager)
class LiveQuestionsManager: RCTViewManager {
  override func view() -> UIView! {
    return RNLiveQuestions()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
