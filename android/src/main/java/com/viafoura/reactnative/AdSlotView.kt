package com.viafoura.reactnative

import android.content.Context
import com.facebook.react.bridge.ReactContext
import com.facebook.react.views.view.ReactViewGroup

class AdSlotView(context: Context) : ReactViewGroup(context) {
  var position: Int = 0

  var adHeight: Int = 0
    set(value) {
      if (field == value) return
      field = value
      onContentSizeChange?.invoke()
    }

  var onContentSizeChange: (() -> Unit)? = null


  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    val width = MeasureSpec.getSize(widthMeasureSpec)
    val height = MeasureSpec.getSize(heightMeasureSpec)
    val childWidthSpec = MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY)
    val childHeightSpec = MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
    for (index in 0 until childCount) {
      getChildAt(index).measure(childWidthSpec, childHeightSpec)
    }
    setMeasuredDimension(width, height)
  }

  override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    val width = r - l
    val height = b - t
    for (index in 0 until childCount) {
      getChildAt(index).layout(0, 0, width, height)
    }
  }

  val contentHeightPx: Int
    get() = if (adHeight > 0) {
      (adHeight * resources.displayMetrics.density).toInt()
    } else {
      0
    }
}
