package expo.modules.viafourasdk

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView

// Viafoura SDK imports
import com.viafourasdk.src.fragments.base.VFFragment
import com.viafourasdk.src.fragments.previewcomments.VFPreviewCommentsFragment
import com.viafourasdk.src.fragments.previewcomments.VFPreviewCommentsFragmentBuilder
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFAdInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.interfaces.VFLayoutInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFArticleMetadata
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import java.net.URL

class PreviewCommentsView(context: Context, appContext: AppContext) :
  ExpoView(context, appContext), VFCustomUIInterface, VFActionsInterface, VFLayoutInterface, VFAdInterface {

  // Props
  var containerId: String? = null
  var authorId: String? = null
  var articleUrl: String? = null
  var articleTitle: String? = null
  var articleSubtitle: String? = null
  var articleThumbnailUrl: String? = null
  var syndicationKey: String? = null
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
  var adInterval: Int = 0
  var firstAdPosition: Int = 2

  // Events
  private val onHeightChanged by EventDispatcher()
  private val onAuthNeeded by EventDispatcher()
  private val onOpenProfile by EventDispatcher()
  private val onNewComment by EventDispatcher()
  private val onArticlePressed by EventDispatcher()
  private val onAction by EventDispatcher()
  private val onAdSlotRequested by EventDispatcher()

  // Internals
  // FragmentContainerView (not a plain FrameLayout) is required to host a fragment:
  // replace()-ing into a plain FrameLayout can run the fragment lifecycle without ever
  // attaching its view, leaving the host blank.
  private val container = FragmentContainerView(context).also {
    it.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    it.id = ViewCompat.generateViewId()
    addView(it)
  }

  private var fragment: VFPreviewCommentsFragment? = null

  private val adContainers = mutableMapOf<Int, FrameLayout>()
  private val adSlots = mutableMapOf<Int, AdSlotView>()
  private val reactChildren = mutableListOf<View>()

  // On the new architecture (Fabric), native child views added imperatively to an
  // ExpoView are never measured/laid out by React's layout system, so the hosted
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
    appContext.currentActivity as? FragmentActivity

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

      val builder = VFPreviewCommentsFragmentBuilder(requireNotNull(containerId), meta, settings)
      syndicationKey?.let { builder.syndicationKey(it) }
      val frag = builder.build()
      frag.setActionCallback(this)
      frag.setLayoutCallback(this)
      frag.setCustomUICallback(this)
      frag.setAdInterface(this)
      frag.setTheme(resolvedTheme)
      authorId?.let { if (it.isNotEmpty()) frag.setAuthorIds(listOf(it)) }

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
      VFActionType.trendingArticlePressed -> {
        val url = action?.trendingPressedAction?.articleMetadata?.url?.toString()
        val containerId = action?.trendingPressedAction?.containerId ?: ""
        url?.let { actionPayload["articleUrl"] = it }
        actionPayload["containerId"] = containerId
        if (url != null) {
          onArticlePressed(mapOf("articleUrl" to url, "containerId" to containerId))
        }
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

  // VFAdInterface
  override fun getAdInterval(fragment: VFFragment?): Int = adInterval

  override fun getFirstAdPosition(fragment: VFFragment?): Int = firstAdPosition

  override fun generateAd(fragment: VFFragment?, adPosition: Int): ViewGroup? {
    if (adInterval <= 0) return null

    adContainers[adPosition]?.let { return it }

    val adContainer = FrameLayout(context).also {
      it.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0)
    }
    adContainers[adPosition] = adContainer

    val slot = adSlots[adPosition]
    if (slot != null) {
      attachSlot(slot, adContainer)
    } else {
      onAdSlotRequested(mapOf("position" to adPosition, "containerId" to (containerId ?: "")))
    }

    return adContainer
  }

  // Ad slots
  val reactChildCount: Int
    get() = reactChildren.size

  fun reactChildAt(index: Int): View? = reactChildren.getOrNull(index)

  fun addReactChild(child: View, index: Int) {
    reactChildren.add(index.coerceIn(0, reactChildren.size), child)
    if (child is AdSlotView) {
      registerAdSlot(child)
    }
  }

  fun removeReactChildAt(index: Int) {
    reactChildren.getOrNull(index)?.let { removeReactChild(it) }
  }

  fun removeReactChild(child: View) {
    reactChildren.remove(child)
    if (child is AdSlotView) {
      unregisterAdSlot(child)
    }
  }

  private fun registerAdSlot(slot: AdSlotView) {
    adSlots[slot.position] = slot
    slot.onContentSizeChange = {
      adContainers[slot.position]?.let { updateContainerHeight(slot, it) }
    }
    adContainers[slot.position]?.let { attachSlot(slot, it) }
  }

  private fun unregisterAdSlot(slot: AdSlotView) {
    slot.onContentSizeChange = null
    if (adSlots[slot.position] === slot) {
      adSlots.remove(slot.position)
    }
    (slot.parent as? ViewGroup)?.removeView(slot)
    adContainers[slot.position]?.let { container ->
      val params = container.layoutParams ?: return@let
      params.height = 0
      container.layoutParams = params
      container.requestLayout()
    }
  }

  private fun attachSlot(slot: AdSlotView, adContainer: FrameLayout) {
    if (slot.parent !== adContainer) {
      (slot.parent as? ViewGroup)?.removeView(slot)
      adContainer.addView(
        slot,
        FrameLayout.LayoutParams(
          FrameLayout.LayoutParams.MATCH_PARENT,
          FrameLayout.LayoutParams.MATCH_PARENT
        )
      )
    }
    updateContainerHeight(slot, adContainer)
  }

  private fun updateContainerHeight(slot: AdSlotView, adContainer: FrameLayout) {
    val height = slot.contentHeightPx
    val params = adContainer.layoutParams
      ?: ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height)
    if (params.height == height) return
    params.height = height
    adContainer.layoutParams = params
    adContainer.requestLayout()
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
