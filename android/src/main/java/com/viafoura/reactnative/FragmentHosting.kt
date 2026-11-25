package com.viafoura.reactnative

import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView

internal fun View.repost(action: Runnable?) {
  if (action == null) return
  removeCallbacks(action)
  post(action)
}

internal fun FragmentContainerView.removeHostedFragment(activity: FragmentActivity?, hosted: Fragment?) {
  val manager = activity?.supportFragmentManager
  val frag = manager?.findFragmentByTag(id.toString()) ?: hosted
  if (manager != null && frag != null) {
    try {
      manager.beginTransaction().remove(frag).commitNowAllowingStateLoss()
    } catch (_: IllegalStateException) {
      manager.beginTransaction().remove(frag).commitAllowingStateLoss()
    }
  }
  removeAllViews()
}
