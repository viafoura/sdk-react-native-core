package com.viafoura.reactnative

import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.widget.ImageViewCompat
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import kotlin.math.roundToInt

data class CustomUIStyle(
  val visibility: String? = null,
  val backgroundColor: String? = null,
  val textColor: String? = null,
  val tintColor: String? = null,
  val fontFamily: String? = null,
  val fontSize: Float? = null,
  val cornerRadius: Float? = null,
  val borderColor: String? = null,
  val borderWidth: Float? = null,
  val opacity: Float? = null
) {
  fun mergedOver(existing: CustomUIStyle?): CustomUIStyle {
    if (existing == null) return this
    return CustomUIStyle(
      visibility = visibility ?: existing.visibility,
      backgroundColor = backgroundColor ?: existing.backgroundColor,
      textColor = textColor ?: existing.textColor,
      tintColor = tintColor ?: existing.tintColor,
      fontFamily = fontFamily ?: existing.fontFamily,
      fontSize = fontSize ?: existing.fontSize,
      cornerRadius = cornerRadius ?: existing.cornerRadius,
      borderColor = borderColor ?: existing.borderColor,
      borderWidth = borderWidth ?: existing.borderWidth,
      opacity = opacity ?: existing.opacity
    )
  }

  companion object {
    fun fromReadableMap(map: ReadableMap): CustomUIStyle {
      fun string(key: String): String? =
        if (map.hasKey(key) && map.getType(key) == ReadableType.String) map.getString(key) else null

      fun number(key: String): Float? =
        if (map.hasKey(key) && map.getType(key) == ReadableType.Number) map.getDouble(key).toFloat() else null

      return CustomUIStyle(
        visibility = string("visibility"),
        backgroundColor = string("backgroundColor"),
        textColor = string("textColor"),
        tintColor = string("tintColor"),
        fontFamily = string("fontFamily"),
        fontSize = number("fontSize"),
        cornerRadius = number("cornerRadius"),
        borderColor = string("borderColor"),
        borderWidth = number("borderWidth"),
        opacity = number("opacity")
      )
    }
  }
}

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
    stylePolicies[key] = style.mergedOver(stylePolicies[key])
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
    val runnable = Runnable { apply(view, style) }
    if (Looper.myLooper() == Looper.getMainLooper()) {
      runnable.run()
    } else {
      Handler(Looper.getMainLooper()).post(runnable)
    }
  }

  private fun apply(view: View, style: CustomUIStyle) {
    style.visibility?.let { value ->
      view.visibility = if (value == "hidden") View.GONE else View.VISIBLE
    }
    applyBackground(view, style)
    style.textColor?.let { value ->
      parseColor(value)?.let { color -> (view as? TextView)?.setTextColor(color) }
    }
    style.tintColor?.let { value ->
      parseColor(value)?.let { color ->
        (view as? ImageView)?.let { ImageViewCompat.setImageTintList(it, ColorStateList.valueOf(color)) }
      }
    }
    if (style.fontFamily != null || style.fontSize != null) {
      (view as? TextView)?.let { applyFont(it, style.fontFamily, style.fontSize) }
    }
    style.opacity?.let { view.alpha = it.coerceIn(0f, 1f) }
  }

  private fun applyBackground(view: View, style: CustomUIStyle) {
    val backgroundColor = style.backgroundColor?.let { parseColor(it) }
    val borderColor = style.borderColor?.let { parseColor(it) }
    val needsShape = style.cornerRadius != null || style.borderWidth != null || borderColor != null
    if (!needsShape) {
      backgroundColor?.let { view.setBackgroundColor(it) }
      return
    }

    val density = view.resources.displayMetrics.density
    val existing = view.background
    val drawable = (existing as? GradientDrawable)?.mutate() as? GradientDrawable
      ?: GradientDrawable().also { shape ->
        shape.setColor((existing as? ColorDrawable)?.color ?: Color.TRANSPARENT)
      }
    backgroundColor?.let { drawable.setColor(it) }
    style.cornerRadius?.let { drawable.cornerRadius = it * density }
    if (style.borderWidth != null || borderColor != null) {
      val requested = style.borderWidth ?: 1f
      val width = if (requested > 0f) (requested * density).roundToInt().coerceAtLeast(1) else 0
      drawable.setStroke(width, borderColor ?: Color.TRANSPARENT)
    }
    view.background = drawable
    view.clipToOutline = (style.cornerRadius ?: 0f) > 0f
  }

  private fun applyFont(view: TextView, fontFamily: String?, fontSize: Float?) {
    fontFamily?.let { name ->
      loadTypeface(view.context, name)?.let { typeface ->
        view.typeface = Typeface.create(typeface, view.typeface?.style ?: Typeface.NORMAL)
      }
    }
    fontSize?.let { view.setTextSize(TypedValue.COMPLEX_UNIT_SP, it) }
  }

  private fun parseColor(value: String): Int? {
    return try {
      Color.parseColor(value)
    } catch (error: IllegalArgumentException) {
      null
    }
  }
}
