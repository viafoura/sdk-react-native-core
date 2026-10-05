package com.viafoura.reactnative

import android.content.Context
import android.graphics.Typeface
import com.viafourasdk.src.model.local.VFDefaultFonts
import com.viafourasdk.src.model.local.VFFonts

private const val KEY_FONT_LIGHT = "fontLight"
private const val KEY_FONT_REGULAR = "fontRegular"
private const val KEY_FONT_MEDIUM = "fontMedium"
private const val KEY_FONT_SEMIBOLD = "fontSemibold"
private const val KEY_FONT_BOLD = "fontBold"

private val FONT_ASSET_EXTENSIONS = listOf("ttf", "otf")

internal fun resolveVFFonts(context: Context, fonts: Map<String, Any?>?): VFFonts {
  val defaults = VFDefaultFonts.getInstance()
  return VFFonts().apply {
    fontLight = loadTypeface(context, fonts?.get(KEY_FONT_LIGHT)) ?: defaults.fontLightDefault
    fontRegular = loadTypeface(context, fonts?.get(KEY_FONT_REGULAR)) ?: defaults.fontRegularDefault
    fontMedium = loadTypeface(context, fonts?.get(KEY_FONT_MEDIUM)) ?: defaults.fontMediumDefault
    fontSemiBold = loadTypeface(context, fonts?.get(KEY_FONT_SEMIBOLD)) ?: defaults.fontSemiBoldDefault
    fontBold = loadTypeface(context, fonts?.get(KEY_FONT_BOLD)) ?: defaults.fontBoldDefault
  }
}

internal fun loadTypeface(context: Context, value: Any?): Typeface? {
  val name = (value as? String)?.trim()
  if (name.isNullOrEmpty()) return null
  for (extension in FONT_ASSET_EXTENSIONS) {
    try {
      return Typeface.createFromAsset(context.assets, "fonts/$name.$extension")
    } catch (_: RuntimeException) {
    }
  }
  return null
}
