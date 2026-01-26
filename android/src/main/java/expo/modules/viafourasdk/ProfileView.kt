package expo.modules.viafourasdk

import android.content.Context
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView

// Viafoura SDK imports
import com.viafourasdk.src.fragments.profile.VFProfileFragment
import com.viafourasdk.src.fragments.profile.VFProfileFragmentBuilder
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.interfaces.VFLayoutInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFProfilePresentationType
import com.viafourasdk.src.model.local.VFTheme
import java.util.UUID

class ProfileView(context: Context, appContext: AppContext) :
  ExpoView(context, appContext), VFCustomUIInterface, VFActionsInterface, VFLayoutInterface {

  // Props
  var userUUID: String? = null
  var presentationType: String? = null // "profile" | "feed"
  var darkMode: Boolean = false
  var colors: Map<String, Any?>? = null

  // Events
  private val onAuthNeeded by EventDispatcher()
  private val onCloseProfile by EventDispatcher()
  private val onAction by EventDispatcher()

  // Internals
  private val container = FrameLayout(context).also {
    it.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
    it.id = ViewCompat.generateViewId()
    addView(it)
  }
  private var fragment: VFProfileFragment? = null

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
      val settings = VFSettings(
        resolveVFColors(colors, if (darkMode) VFTheme.dark else VFTheme.light)
      )

      val pres = when (presentationType) {
        "feed" -> VFProfilePresentationType.feed
        else -> VFProfilePresentationType.profile
      }

      val uuid = UUID.fromString(requireNotNull(userUUID))
      val frag = VFProfileFragmentBuilder(uuid, pres, settings).build()
      frag.setActionCallback(this)
      frag.setCustomUICallback(this)
      frag.setTheme(if (darkMode) VFTheme.dark else VFTheme.light)

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
  override fun onNewAction(actionType: VFActionType, action: VFActionData) {
    val actionPayload = mutableMapOf<String, Any>("type" to actionType.toString())
    when (actionType) {
      VFActionType.closeProfilePressed -> {
        onCloseProfile(emptyMap<String, Any>())
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
  ) { /* no-op */ }

  // VFLayoutInterface
  override fun containerHeightUpdated(
    fragment: com.viafourasdk.src.fragments.base.VFFragment,
    containerId: String,
    height: Int
  ) { /* no-op for profile */ }
}
