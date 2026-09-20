package expo.modules.viafourasdk

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class AdSlotModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ViafouraAdSlot")

    View(AdSlotView::class) {
      Prop("position") { view: AdSlotView, v: Int -> view.position = v }
      Prop("adHeight") { view: AdSlotView, v: Int? -> view.adHeight = v ?: 0 }
    }
  }
}
