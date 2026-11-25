package com.viafoura.reactnative

import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.OnBackPressedCallback
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.viafourasdk.src.fragments.profile.VFProfileFragment
import com.viafourasdk.src.fragments.profile.VFProfileFragmentBuilder
import com.viafourasdk.src.interfaces.VFActionsInterface
import com.viafourasdk.src.interfaces.VFCustomUIInterface
import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFCustomViewType
import com.viafourasdk.src.model.local.VFDefaultColors
import com.viafourasdk.src.model.local.VFNotificationPresentationAction
import com.viafourasdk.src.model.local.VFProfilePresentationType
import com.viafourasdk.src.model.local.VFProfileStyle
import com.viafourasdk.src.model.local.VFSettings
import com.viafourasdk.src.model.local.VFTheme
import java.util.UUID

private const val ANIMATION_DURATION_MS = 250L

/**
 * Presents VFProfileFragment full screen over the current activity, outside React's view
 * tree, so `Viafoura.presentProfile` behaves like the iOS sheet. Member profiles opened from
 * inside it stack as further layers; Back and the close button pop one layer at a time.
 */
internal class ProfileSheet(
  private val activity: FragmentActivity,
  options: Map<String, Any?>,
  private val emit: (event: String, payload: Map<String, Any?>?) -> Unit
) : VFActionsInterface, VFCustomUIInterface, DefaultLifecycleObserver {

  private class Layer(
    val container: FrameLayout,
    val fragment: VFProfileFragment,
    val backCallback: OnBackPressedCallback
  )

  private val theme: VFTheme = when ((options["theme"] as? String)?.lowercase()) {
    "dark" -> VFTheme.dark
    "light" -> VFTheme.light
    else -> if (options["darkMode"] == true) VFTheme.dark else VFTheme.light
  }

  private val style: VFProfileStyle =
    if ((options["profileStyle"] as? String)?.lowercase() == "unity") VFProfileStyle.unity
    else VFProfileStyle.legacy

  @Suppress("UNCHECKED_CAST")
  private val settings = VFSettings(
    resolveVFColors(options["colors"] as? Map<String, Any?>, theme),
    resolveVFFonts(activity, options["fonts"] as? Map<String, Any?>)
  )

  private val layers = mutableListOf<Layer>()
  private var closed = false

  fun present(userUUID: UUID, presentationType: VFProfilePresentationType) {
    if (closed) return
    val root = activity.findViewById<ViewGroup>(android.R.id.content)
    if (layers.isEmpty()) activity.lifecycle.addObserver(this)

    val container = FrameLayout(activity).apply {
      id = View.generateViewId()
      layoutParams = FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT
      )
      setBackgroundColor(VFDefaultColors.getInstance().colorBackgroundDefault(theme))
      // Keeps touches from reaching the React views underneath.
      isClickable = true
    }
    // The fragment pads for the navigation bar itself; the status bar is ours to avoid.
    ViewCompat.setOnApplyWindowInsetsListener(container) { view, insets ->
      view.updatePadding(top = insets.getInsets(WindowInsetsCompat.Type.statusBars()).top)
      insets
    }
    root.addView(container)
    ViewCompat.requestApplyInsets(container)

    val fragment = VFProfileFragmentBuilder(userUUID, presentationType, settings).style(style).build()
    fragment.setActionCallback(this)
    fragment.setCustomUICallback(this)
    fragment.setTheme(theme)

    // Registered before the fragment commits so that the unity drawer's own Back callback,
    // added in onViewCreated, runs first and only falls through to this one once it has no
    // inner screen left to pop.
    val backCallback = object : OnBackPressedCallback(true) {
      override fun handleOnBackPressed() = popLayer()
    }
    activity.onBackPressedDispatcher.addCallback(backCallback)

    // Added headless and attached by hand, as ProfileView does, so the fragment's view
    // always lands in our container whatever view host the FragmentManager resolves.
    activity.supportFragmentManager
      .beginTransaction()
      .add(fragment, "viafoura-profile-sheet-${container.id}")
      .commitNow()
    fragment.view?.let { view ->
      (view.parent as? ViewGroup)?.removeView(view)
      container.addView(
        view,
        ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
      )
    }

    layers.add(Layer(container, fragment, backCallback))

    container.translationY = root.height.toFloat()
    container.animate().translationY(0f).setDuration(ANIMATION_DURATION_MS).start()
  }

  private fun popLayer() {
    val layer = layers.removeLastOrNull() ?: return
    if (layers.isEmpty()) {
      dismiss(layer)
    } else {
      animateOut(layer) { removeLayer(layer) }
    }
  }

  private fun dismissAll(then: () -> Unit = {}) {
    val top = layers.removeLastOrNull()
    if (top == null) {
      then()
      return
    }
    layers.toList().forEach { removeLayer(it) }
    layers.clear()
    dismiss(top, then)
  }

  private fun dismiss(top: Layer, then: () -> Unit = {}) {
    closed = true
    animateOut(top) {
      removeLayer(top)
      finish()
      then()
    }
  }

  private fun animateOut(layer: Layer, end: () -> Unit) {
    layer.backCallback.remove()
    layer.container.isClickable = false
    layer.container.animate()
      .translationY(layer.container.height.toFloat())
      .setDuration(ANIMATION_DURATION_MS)
      .withEndAction(end)
      .start()
  }

  private fun removeLayer(layer: Layer) {
    layer.backCallback.remove()
    val manager = activity.supportFragmentManager
    try {
      manager.beginTransaction().remove(layer.fragment).commitNowAllowingStateLoss()
    } catch (_: IllegalStateException) {
      manager.beginTransaction().remove(layer.fragment).commitAllowingStateLoss()
    }
    layer.container.removeAllViews()
    (layer.container.parent as? ViewGroup)?.removeView(layer.container)
  }

  private fun finish() {
    activity.lifecycle.removeObserver(this)
    emit("close", null)
  }

  override fun onDestroy(owner: LifecycleOwner) {
    if (closed) return
    closed = true
    layers.forEach { removeLayer(it) }
    layers.clear()
    finish()
  }

  // VFActionsInterface
  override fun onNewAction(actionType: VFActionType, action: VFActionData?) {
    val payload = profileActionPayload(actionType, action)
    when (actionType) {
      VFActionType.closeProfilePressed -> {
        emit("action", payload)
        popLayer()
      }
      VFActionType.openProfilePressed -> {
        emit("action", payload)
        action?.openProfileAction?.let {
          present(it.userUUID, it.presentationType ?: VFProfilePresentationType.profile)
        }
      }
      VFActionType.notificationPressed -> {
        val notification = action?.notificationPresentationAction
        val memberUUID = notification?.userUUID
        if (notification?.notificationPresentationType ==
          VFNotificationPresentationAction.VFNotificationPresentationType.profile && memberUUID != null
        ) {
          emit("action", payload)
          present(memberUUID, VFProfilePresentationType.profile)
        } else {
          dismissAll { emit("action", payload) }
        }
      }
      VFActionType.trendingArticlePressed -> dismissAll { emit("action", payload) }
      VFActionType.authPressed -> dismissAll {
        emit("action", payload)
        emit("authNeeded", authNeededPayload(action))
      }
      else -> emit("action", payload)
    }
  }

  // VFCustomUIInterface
  override fun customizeView(theme: VFTheme?, customViewType: VFCustomViewType?, view: View?) {
    if (customViewType == null || view == null) return
    val style = CustomUIViewRegistry.getStyle(customViewType.name, theme?.name?.lowercase()) ?: return
    CustomUIViewRegistry.applyStyle(view, style)
  }
}
