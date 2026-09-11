import Foundation

@objc(RNLiveQuestionsManager)
class RNLiveQuestionsManager : RCTViewManager {
  override class func requiresMainQueueSetup() -> Bool {
    return true
  }

  override func view() -> UIView! {
    return RNLiveQuestions()
  }
}
