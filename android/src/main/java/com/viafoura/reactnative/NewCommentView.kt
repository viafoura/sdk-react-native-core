package com.viafoura.reactnative

import android.content.Context
import com.facebook.react.bridge.ReactContext
import com.facebook.react.views.view.ReactViewGroup
import android.view.ViewGroup
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView

// Viafoura SDK imports
import com.viafourasdk.src.fragments.base.VFFragment
import com.viafourasdk.src.fragments.newcomment.VFNewCommentFragment
import com.viafourasdk.src.fragments.newcomment.VFNewCommentFragmentBuilder
import com.viafourasdk.src.model.local.VFNewCommentAction
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.interfaces.VFLayoutInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFArticleMetadata
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import java.net.URL
import java.util.UUID

class NewCommentView(context: Context) :
  ReactViewGroup(context), VFCustomUIInterface, VFActionsInterface, VFLayoutInterface {

  // Props
  var newCommentActionType: String = "create" // create | edit | reply
  var content: String? = null
  var containerId: String? = null
  var syndicationKey: String? = null
  var articleTitle: String? = null
  var articleSubtitle: String? = null
  var articleUrl: String? = null
  var articleThumbnailUrl: String? = null
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
  private val onAuthNeeded by viafouraEvent()
  private val onCloseNewComment by viafouraEvent()
  private val onHeightChanged by viafouraEvent()
  private val onAction by viafouraEvent()

  // Internals
  private val container = FragmentContainerView(context).also {
    it.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    it.id = ViewCompat.generateViewId()
    addView(it)
  }
  private var fragment: VFNewCommentFragment? = null

  // On the new architecture (Fabric), native child views added imperatively to an
  // interop views are never measured/laid out by React's layout system, so the hosted
  // fragment renders at 0x0 and appears blank. Force a manual measure+layout pass.
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
    // Defer to after any in-flight FragmentManager transaction. When this view is reached
    // via navigation, react-native-screens is mid-transaction committing the screen push as
    // we attach; committing synchronously here throws "FragmentManager is already executing
    // transactions". Posting runs our transaction once the FM is idle.
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
      val metadata = VFArticleMetadata(
        URL(requireNotNull(articleUrl)),
        requireNotNull(articleTitle),
        articleSubtitle ?: "",
        URL(requireNotNull(articleThumbnailUrl))
      )
      val settings = VFSettings(
        resolveVFColors(colors, resolvedTheme)
      )

      val type = when (newCommentActionType) {
        "edit" -> VFNewCommentAction.VFNewCommentActionType.edit
        "reply" -> VFNewCommentAction.VFNewCommentActionType.reply
        else -> VFNewCommentAction.VFNewCommentActionType.create
      }
      val action = VFNewCommentAction(type)
      content?.let { c ->
        if (c.isNotEmpty()) action.content = UUID.fromString(c)
      }

      val builder = VFNewCommentFragmentBuilder(action, requireNotNull(containerId), metadata, settings)
      syndicationKey?.let { builder.syndicationKey(it) }
      val frag = builder.build()
      frag.setActionCallback(this)
      frag.setCustomUICallback(this)
      frag.setTheme(resolvedTheme)

      // Add the fragment "headless" (no container view id). When a container id is
      // supplied, the FragmentManager — running under the React/Fabric view host — resolves
      // the wrong container and attaches the fragment's view to the React root surface
      // instead of ours, leaving this view blank. Adding headless lets us own the view
      // attachment and place it into our container explicitly.
      activity.supportFragmentManager
        .beginTransaction()
        .add(frag, container.id.toString())
        .commitNow()

      fragment = frag

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
    val frag: Fragment? = activity.supportFragmentManager.findFragmentByTag(tag)
    if (frag != null) {
      activity.supportFragmentManager
        .beginTransaction()
        .remove(frag)
        .commit()
    }
    fragment = null
  }

  // VFActionsInterface
  override fun onNewAction(actionType: VFActionType, action: VFActionData?) {
    val actionPayload = mutableMapOf<String, Any>("type" to actionType.toString())
    when (actionType) {
      VFActionType.closeNewCommentPressed -> {
        onCloseNewComment(emptyMap<String, Any>())
      }
      VFActionType.authPressed -> {
        actionPayload["requireLogin"] = true
        onAuthNeeded(mapOf("requireLogin" to true))
      }
      else -> {}
    }
    onAction(actionPayload)
  }

  // VFCustomUIInterface
  override fun customizeView(
    theme: com.viafourasdk.src.model.local.VFTheme?,
    customViewType: com.viafourasdk.src.model.local.VFCustomViewType?,
    view: android.view.View?
  ) {
    if (customViewType == null || view == null) return
    val themeName = theme?.name?.lowercase()
    val viewTypeName = customViewType.name
    val style = CustomUIViewRegistry.getStyle(viewTypeName, themeName) ?: return
    CustomUIViewRegistry.applyStyle(view, style)
  }

  // VFLayoutInterface
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
