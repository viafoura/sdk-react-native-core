package com.viafoura.reactnative

import android.content.Context
import android.util.Log
import android.view.ViewGroup
import com.facebook.react.views.view.ReactViewGroup

import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import com.viafourasdk.src.view.notificationBell.VFNotificationBellView

class NotificationBellView(context: Context) : ReactViewGroup(context) {

  var darkMode: Boolean = false
    set(value) {
      field = value
      applyThemeIfReady()
    }
  var theme: String? = null
    set(value) {
      field = value
      applyThemeIfReady()
    }
  var colors: Map<String, Any?>? = null
  var fonts: Map<String, Any?>? = null
  var elevationEnabled: Boolean = false
    set(value) {
      field = value
      bellView?.setElevationEnabled(value)
    }
  var backgroundColorEnabled: Boolean = true
    set(value) {
      field = value
      bellView?.setBackgroundColorEnabled(value)
    }

  private val onBellPressed by viafouraEvent()
  private val onAuthNeeded by viafouraEvent()
  private val onAction by viafouraEvent()

  private var bellView: VFNotificationBellView? = null

  private val measureAndLayout = Runnable {
    measure(
      MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
    )
    layout(left, top, right, bottom)
    bellView?.let {
      it.measure(
        MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
        MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
      )
      it.layout(0, 0, width, height)
    }
  }

  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    post(measureAndLayout)
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    ensureBell()
  }

  private fun ensureBell() {
    if (bellView != null) return

    try {
      val resolvedTheme = resolveTheme()
      val settings = VFSettings(
        resolveVFColors(colors, resolvedTheme),
        resolveVFFonts(context, fonts)
      )

      // Only the AttributeSet constructor inflates the bell layout; the Context-only one leaves it empty.
      val bell = VFNotificationBellView(context, null)
      bell.applySettings(settings)
      bell.setTheme(resolvedTheme)
      bell.setElevationEnabled(elevationEnabled)
      bell.setBackgroundColorEnabled(backgroundColorEnabled)
      bell.setBellClickedInterface { userUUID ->
        val payload = mapOf("userUUID" to userUUID.toString())
        onBellPressed(payload)
        onAction(payload + ("type" to "bellPressed"))
      }
      bell.setActionCallback { actionType: VFActionType, _: VFActionData? ->
        val actionPayload = mutableMapOf<String, Any>("type" to actionType.toString())
        if (actionType == VFActionType.authPressed) {
          actionPayload["requireLogin"] = true
          onAuthNeeded(mapOf("requireLogin" to true))
        }
        onAction(actionPayload)
      }
      bell.setCustomUICallback { theme, customViewType, view ->
        if (customViewType == null || view == null) return@setCustomUICallback
        val themeName = theme?.name?.lowercase()
        val style = CustomUIViewRegistry.getStyle(customViewType.name, themeName) ?: return@setCustomUICallback
        CustomUIViewRegistry.applyStyle(view, style)
      }

      addView(
        bell,
        ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT,
          ViewGroup.LayoutParams.MATCH_PARENT
        )
      )
      bellView = bell
      post(measureAndLayout)
    } catch (e: Exception) {
      Log.w("NotificationBellView", "Could not create notification bell", e)
    }
  }

  private fun resolveTheme(): VFTheme {
    return when (theme?.lowercase()) {
      "dark" -> VFTheme.dark
      "light" -> VFTheme.light
      else -> if (darkMode) VFTheme.dark else VFTheme.light
    }
  }

  private fun applyThemeIfReady() {
    bellView?.setTheme(resolveTheme())
  }
}
