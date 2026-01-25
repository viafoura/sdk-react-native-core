package expo.modules.viafourasdk

import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView

// Viafoura SDK imports
import com.viafourasdk.src.fragments.base.VFFragment
import com.viafourasdk.src.fragments.previewcomments.VFPreviewCommentsFragment
import com.viafourasdk.src.fragments.previewcomments.VFPreviewCommentsFragmentBuilder
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.interfaces.VFLayoutInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFArticleMetadata
import com.viafourasdk.src.model.local.VFColors
import com.viafourasdk.src.model.local.VFDefaultColors
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import java.net.URL

class PreviewCommentsView(context: Context, appContext: AppContext) :
  ExpoView(context, appContext), VFCustomUIInterface, VFActionsInterface, VFLayoutInterface {

  // Props
  var containerId: String? = null
  var authorId: String? = null
  var articleUrl: String? = null
  var articleTitle: String? = null
  var articleSubtitle: String? = null
  var articleThumbnailUrl: String? = null
  var syndicationKey: String? = null
  var darkMode: Boolean = false

  // Events
  private val onHeightChanged by EventDispatcher()
  private val onAuthNeeded by EventDispatcher()
  private val onOpenProfile by EventDispatcher()
  private val onNewComment by EventDispatcher()
  private val onArticlePressed by EventDispatcher()

  // Internals
  private val container = FrameLayout(context).also {
    it.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    it.id = ViewCompat.generateViewId()
    addView(it)
  }

  private var fragment: VFPreviewCommentsFragment? = null

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    ensureFragment()
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    destroyFragment()
  }

  private fun currentActivity(): FragmentActivity? =
    appContext.currentActivity as? FragmentActivity

  private fun ensureFragment() {
    if (fragment != null) return
    val activity = currentActivity() ?: return

    try {
      val meta = VFArticleMetadata(
        URL(requireNotNull(articleUrl)),
        requireNotNull(articleTitle),
        articleSubtitle ?: "",
        URL(requireNotNull(articleThumbnailUrl))
      )
      val colors = VFColors(
        VFDefaultColors.getInstance().colorPrimaryDefault(null),
        VFDefaultColors.getInstance().colorPrimaryLightDefault(null)
      )
      val settings = VFSettings(colors)

      val builder = VFPreviewCommentsFragmentBuilder(requireNotNull(containerId), meta, settings)
      syndicationKey?.let { builder.syndicationKey(it) }
      val frag = builder.build()
      frag.setActionCallback(this)
      frag.setLayoutCallback(this)
      frag.setCustomUICallback(this)
      frag.setTheme(if (darkMode) VFTheme.dark else VFTheme.light)
      authorId?.let { if (it.isNotEmpty()) frag.setAuthorIds(listOf(it)) }

      activity.supportFragmentManager
        .beginTransaction()
        .replace(container.id, frag, container.id.toString())
        .commit()

      fragment = frag
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
  ) { /* no-op */ }

  // VFActionsInterface
  override fun onNewAction(actionType: VFActionType, action: VFActionData) {
    when (actionType) {
      VFActionType.writeNewCommentPressed -> {
        val payload = mutableMapOf<String, Any>()
        action.newCommentAction?.content?.toString()?.let { payload["content"] = it }
        action.newCommentAction?.type?.toString()?.let { payload["actionType"] = it }
        onNewComment(payload)
      }
      VFActionType.openProfilePressed -> {
        val payload = mutableMapOf<String, Any>()
        action.openProfileAction?.presentationType?.toString()?.let { payload["presentationType"] = it }
        action.openProfileAction?.userUUID?.toString()?.let { payload["userUUID"] = it }
        onOpenProfile(payload)
      }
      VFActionType.trendingArticlePressed -> {
        val url = action.trendingPressedAction?.articleMetadata?.url?.toString() ?: return
        val containerId = action.trendingPressedAction?.containerId ?: ""
        onArticlePressed(mapOf("articleUrl" to url, "containerId" to containerId))
      }
      VFActionType.authPressed -> {
        onAuthNeeded(mapOf("requireLogin" to true))
      }
      else -> {}
    }
  }

  // VFLayoutInterface
  override fun containerHeightUpdated(fragment: VFFragment, containerId: String, height: Int) {
    onHeightChanged(mapOf("newHeight" to height, "containerId" to containerId))
  }
}
