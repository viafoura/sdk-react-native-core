package com.viafoura.reactnative

import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View

data class CustomUIStyle(
  val visibility: String? = null,
  val backgroundColor: String? = null
)

object CustomUIViewRegistry {
  private val stylePolicies = mutableMapOf<String, CustomUIStyle>()

  private fun policyKey(viewType: String, theme: String?): String {
    val normalizedTheme = theme?.lowercase()
    return if (normalizedTheme.isNullOrBlank()) {
      viewType
    } else {
      "$viewType#$normalizedTheme"
    }
  }

  @Synchronized
  fun setStyle(viewType: String, style: CustomUIStyle, theme: String?) {
    val key = policyKey(viewType, theme)
    val existing = stylePolicies[key]
    val merged = CustomUIStyle(
      visibility = style.visibility ?: existing?.visibility,
      backgroundColor = style.backgroundColor ?: existing?.backgroundColor
    )
    stylePolicies[key] = merged
  }

  @Synchronized
  fun clearStyle(viewType: String, theme: String?) {
    stylePolicies.remove(policyKey(viewType, theme))
  }

  @Synchronized
  fun getStyle(viewType: String, theme: String?): CustomUIStyle? {
    val themed = stylePolicies[policyKey(viewType, theme)]
    return themed ?: stylePolicies[policyKey(viewType, null)]
  }

  fun applyStyle(view: View, style: CustomUIStyle) {
    val runnable = Runnable {
      style.visibility?.let { value ->
        view.visibility = if (value == "hidden") View.GONE else View.VISIBLE
      }
      style.backgroundColor?.let { colorValue ->
        parseColor(colorValue)?.let { parsedColor ->
          view.setBackgroundColor(parsedColor)
        }
      }
    }
    if (Looper.myLooper() == Looper.getMainLooper()) {
      runnable.run()
    } else {
      Handler(Looper.getMainLooper()).post(runnable)
    }
  }

  private fun parseColor(value: String): Int? {
    return try {
      Color.parseColor(value)
    } catch (error: IllegalArgumentException) {
      null
    }
  }
}
