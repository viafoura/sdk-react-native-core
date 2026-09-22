package com.viafoura.reactnative

import android.content.Context
import android.view.ViewGroup
import androidx.core.view.ViewCompat
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import com.facebook.react.views.view.ReactViewGroup

import com.viafourasdk.src.fragments.base.VFFragment
import com.viafourasdk.src.fragments.livequestions.VFLiveQuestionsFragment
import com.viafourasdk.src.fragments.livequestions.VFLiveQuestionsFragmentBuilder
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.interfaces.VFLayoutInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFArticleMetadata
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import java.net.URL

class LiveQuestionsView(context: Context) :
  ReactViewGroup(context), VFCustomUIInterface, VFActionsInterface, VFLayoutInterface {

  // Props
  var containerId: String? = null
  var authorId: String? = null
  var articleUrl: String? = null
  var articleTitle: String? = null
  var articleSubtitle: String? = null
  var articleThumbnailUrl: String? = null
  var liveQuestionsTitle: String? = null
  var sectionUUID: String? = null
  var focusedContentUUID: String? = null
  var limit: Int? = null
  var replyLimit: Int? = null
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

  // Events
  private val onHeightChanged by viafouraEvent()
  private val onAuthNeeded by viafouraEvent()
  private val onOpenProfile by viafouraEvent()
  private val onAction by viafouraEvent()

  private val container = FragmentContainerView(context).also {
    it.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    it.id = ViewCompat.generateViewId()
    addView(it)
  }

  private var fragment: VFLiveQuestionsFragment? = null

  private val measureAndLayout = Runnable {
    measure(
      MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
    )
    layout(left, top, right, bottom)
    container.measure(
      MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
    )
    container.layout(0, 0, width, height)
  }

  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    post { ensureFragment() }
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    destroyFragment()
  }

  private fun currentActivity(): FragmentActivity? =
    reactActivity() as? FragmentActivity

  private fun ensureFragment() {
    if (fragment != null) return
    if (!isAttachedToWindow) return
    val activity = currentActivity() ?: return

    try {
      val resolvedTheme = resolveTheme()
      val meta = VFArticleMetadata(
        URL(requireNotNull(articleUrl)),
        requireNotNull(articleTitle),
        articleSubtitle ?: "",
        URL(requireNotNull(articleThumbnailUrl))
      )
      val settings = VFSettings(
        resolveVFColors(colors, resolvedTheme)
      )

      val builder = VFLiveQuestionsFragmentBuilder(requireNotNull(containerId), meta, settings)
        .actionsInterface(this)
        .customUIInterface(this)
      liveQuestionsTitle?.let { if (it.isNotEmpty()) builder.title(it) }
      sectionUUID?.let { if (it.isNotEmpty()) builder.sectionUUID(it) }
      focusedContentUUID?.let { if (it.isNotEmpty()) builder.focusedContentUUID(it) }
      limit?.let { builder.limit(it) }
      replyLimit?.let { builder.replyLimit(it) }
      val frag = builder.build()
      frag.setLayoutCallback(this)

      activity.supportFragmentManager
        .beginTransaction()
        .add(frag, container.id.toString())
        .commitNow()

      fragment = frag
      frag.setTheme(resolvedTheme)

      val fragView = frag.view
      if (fragView != null) {
        (fragView.parent as? ViewGroup)?.removeView(fragView)
        container.addView(
          fragView,
          ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
          )
        )
      }
    } catch (_: Exception) {
      // Swallow; invalid input
    }
  }

  private fun destroyFragment() {
    val activity = currentActivity() ?: return
    val tag = container.id.toString()
    val frag = activity.supportFragmentManager.findFragmentByTag(tag)
    if (frag != null) {
      activity.supportFragmentManager
        .beginTransaction()
        .remove(frag)
        .commit()
    }
    fragment = null
  }

  override fun customizeView(
    theme: com.viafourasdk.src.model.local.VFTheme?,
    customViewType: com.viafourasdk.src.model.local.VFCustomViewType?,
    view: android.view.View?
  ) {
    if (customViewType == null || view == null) return
    val themeName = theme?.name?.lowercase()
    val style = CustomUIViewRegistry.getStyle(customViewType.name, themeName) ?: return
    CustomUIViewRegistry.applyStyle(view, style)
  }

  override fun onNewAction(actionType: VFActionType, action: VFActionData?) {
    val actionPayload = mutableMapOf<String, Any>("type" to actionType.toString())
    when (actionType) {
      VFActionType.openProfilePressed -> {
        val payload = mutableMapOf<String, Any>()
        action?.openProfileAction?.presentationType?.toString()?.let { payload["presentationType"] = it }
        action?.openProfileAction?.userUUID?.toString()?.let { payload["userUUID"] = it }
        actionPayload.putAll(payload)
        onOpenProfile(payload)
      }
      VFActionType.authPressed -> {
        actionPayload["requireLogin"] = true
        onAuthNeeded(mapOf("requireLogin" to true))
      }
      else -> {}
    }
    onAction(actionPayload)
  }

  override fun containerHeightUpdated(fragment: VFFragment, containerId: String, height: Int) {
    onHeightChanged(mapOf("newHeight" to height, "containerId" to containerId))
  }

  private fun resolveTheme(): VFTheme {
    return when (theme?.lowercase()) {
      "dark" -> VFTheme.dark
      "light" -> VFTheme.light
      else -> if (darkMode) VFTheme.dark else VFTheme.light
    }
  }

  private fun applyThemeIfReady() {
    fragment?.setTheme(resolveTheme())
  }
}
