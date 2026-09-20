import ExpoModulesCore
import UIKit

class RNAdSlot: ExpoView {
  var position: Int = 0
  var adHeight: Double = 0 {
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

  private var reportedSize: CGSize = .zero

  override func layoutSubviews() {
    super.layoutSubviews()
    syncStyleSize()
    onContentSizeChange?()
  }

  private func syncStyleSize() {
#if RCT_NEW_ARCH_ENABLED
    guard !translatesAutoresizingMaskIntoConstraints else { return }
    let size = bounds.size
    guard size.width > 0, size.height > 0 else { return }
    guard abs(size.width - reportedSize.width) > 0.5 || abs(size.height - reportedSize.height) > 0.5 else { return }
    reportedSize = size
    setStyleSize(NSNumber(value: Float(size.width)), height: NSNumber(value: Float(size.height)))
#endif
  }
}

public class AdSlotModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ViafouraAdSlot")

    View(RNAdSlot.self) {
      Prop("position") { (view: RNAdSlot, v: Int) in view.position = v }
      Prop("adHeight") { (view: RNAdSlot, v: Double?) in view.adHeight = v ?? 0 }
    }
  }
}
