import React
import UIKit

class RNAdSlot: UIView {
  @objc var position: Int = 0
  @objc var adHeight: Double = 0 {
    didSet {
      guard adHeight != oldValue else { return }
      onContentSizeChange?()
    }
  }

  var onContentSizeChange: (() -> Void)?

  var contentHeight: CGFloat {
    if adHeight > 0 {
      return CGFloat(adHeight)
    }
    return subviews.reduce(CGFloat(0)) { max($0, $1.frame.maxY) }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    onContentSizeChange?()
  }

}
