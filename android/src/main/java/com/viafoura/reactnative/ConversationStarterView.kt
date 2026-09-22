package com.viafoura.reactnative

import android.content.Context
import com.facebook.react.bridge.ReactContext
import com.facebook.react.views.view.ReactViewGroup
import android.view.ViewGroup
import androidx.core.view.ViewCompat
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView

// Viafoura SDK imports
import com.viafourasdk.src.fragments.base.VFFragment
import com.viafourasdk.src.fragments.conversationstarter.VFConversationStarterFragment
import com.viafourasdk.src.fragments.conversationstarter.VFConversationStarterFragmentBuilder
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.interfaces.VFLayoutInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFArticleMetadata
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import java.net.URL

class ConversationStarterView(context: Context) :
  ReactViewGroup(context), VFCustomUIInterface, VFActionsInterface, VFLayoutInterface {

  // Props
  var containerId: String? = null
  var articleUrl: String? = null
  var articleTitle: String? = null
  var articleSubtitle: String? = null
  var articleThumbnailUrl: String? = null
  var syndicationKey: String? = null
  var starterTitle: String? = null
  var starterDescription: String? = null
  var minimumCommentCount: Int? = null
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
  private val onNewComment by viafouraEvent()
  private val onSeeMoreComments by viafouraEvent()
  private val onAction by viafouraEvent()

  // Internals
  // FragmentContainerView (not a plain FrameLayout) is required to host a fragment:
  // replace()-ing into a plain FrameLayout can run the fragment lifecycle without ever
  // attaching its view, leaving the host blank.
  private val container = FragmentContainerView(context).also {
    it.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    it.id = ViewCompat.generateViewId()
    addView(it)
  }

  private var fragment: VFConversationStarterFragment? = null

  // On the new architecture (Fabric), native child views added imperatively to an
  // interop views are never measured/laid out by React's layout system, so the hosted
  // fragment renders at 0x0 and appears blank. Force a manual measure+layout pass.
  private val measureAndLayout = Runnable {
    measure(
      MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
    )
    layout(left, top, right, bottom)
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
      val meta = VFArticleMetadata(
        URL(requireNotNull(articleUrl)),
        requireNotNull(articleTitle),
        articleSubtitle ?: "",
        URL(requireNotNull(articleThumbnailUrl))
      )
      val settings = VFSettings(
        resolveVFColors(colors, resolvedTheme)
      )

      val builder = VFConversationStarterFragmentBuilder(requireNotNull(containerId), meta, settings)
      syndicationKey?.let { builder.syndicationKey(it) }
      starterTitle?.let { if (it.isNotEmpty()) builder.title(it) }
      starterDescription?.let { if (it.isNotEmpty()) builder.description(it) }
      minimumCommentCount?.let { builder.minimumCommentCount(it) }
      val frag = builder.build()
      frag.setActionCallback(this)
      frag.setLayoutCallback(this)
      frag.setCustomUICallback(this)

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

  // VFActionsInterface
  override fun onNewAction(actionType: VFActionType, action: VFActionData?) {
    val actionPayload = mutableMapOf<String, Any>("type" to actionType.toString())
    when (actionType) {
      VFActionType.seeMoreCommentsPressed -> {
        onSeeMoreComments(emptyMap<String, Any>())
      }
      VFActionType.writeNewCommentPressed -> {
        val payload = mutableMapOf<String, Any>()
        action?.newCommentAction?.content?.toString()?.let { payload["content"] = it }
        action?.newCommentAction?.type?.toString()?.let { payload["actionType"] = it }
        actionPayload.putAll(payload)
        onNewComment(payload)
      }
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
