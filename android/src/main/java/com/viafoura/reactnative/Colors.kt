package com.viafoura.reactnative

import android.graphics.Color
import com.viafourasdk.src.Constants
import com.viafourasdk.src.model.local.VFColors
import com.viafourasdk.src.model.local.VFDefaultColors
import com.viafourasdk.src.model.local.VFTheme

private const val KEY_COLOR_PRIMARY = "colorPrimary"
private const val KEY_COLOR_PRIMARY_LIGHT = "colorPrimaryLight"
private const val KEY_COLOR_AVATARS = "colorAvatars"
private const val KEY_PRIMARY = "primary"
private const val KEY_PRIMARY_LIGHT = "primaryLight"
private const val KEY_AVATARS = "avatars"

internal fun resolveVFColors(colors: Map<String, Any?>?, theme: VFTheme?): VFColors {
  val defaults = VFDefaultColors.getInstance()
  val defaultPrimary = defaults.colorPrimaryDefault(null)
  val defaultPrimaryLight = defaults.colorPrimaryLightDefault(null)

  val primary =
    parseColorOrNull(colors?.get(KEY_COLOR_PRIMARY) ?: colors?.get(KEY_PRIMARY))
      ?: defaultPrimary
  val primaryLight =
    parseColorOrNull(colors?.get(KEY_COLOR_PRIMARY_LIGHT) ?: colors?.get(KEY_PRIMARY_LIGHT))
      ?: defaultPrimaryLight

  val vfColors = VFColors(primary, primaryLight)
  parseAvatarColors(colors?.get(KEY_COLOR_AVATARS) ?: colors?.get(KEY_AVATARS))
    ?.let { vfColors.setColorAvatars(it) }
  theme?.let { vfColors.setTheme(it) }

  return vfColors
}

private fun parseColorOrNull(value: Any?): Int? {
  return when (value) {
    is Int -> value
    is Long -> value.toInt()
    is Number -> value.toInt()
    is String -> {
      if (value.isBlank()) return null
      try {
        Color.parseColor(value)
      } catch (_: IllegalArgumentException) {
        null
      }
    }
    else -> null
  }
}

private fun parseAvatarColors(value: Any?): IntArray? {
  val list = when (value) {
    is List<*> -> value
    is Array<*> -> value.asList()
    else -> return null
  }

  if (list.size != Constants.AVATAR_COLORS.size) return null

  val parsed = IntArray(list.size)
  for (index in list.indices) {
    val color = parseColorOrNull(list[index]) ?: return null
    parsed[index] = color
  }
  return parsed
}
