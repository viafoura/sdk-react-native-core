package com.viafoura.reactnative

import com.viafourasdk.src.model.local.VFActionData
import com.viafourasdk.src.model.local.VFActionType
import com.viafourasdk.src.model.local.VFNotificationPresentationAction
import com.viafourasdk.src.model.local.VFProfilePresentationType

internal fun profileActionPayload(actionType: VFActionType, action: VFActionData?): MutableMap<String, Any> {
  val payload = mutableMapOf<String, Any>("type" to actionType.toString())
  when (actionType) {
    VFActionType.authPressed -> payload.putAll(authNeededPayload(action))
    VFActionType.notificationPressed ->
      action?.notificationPresentationAction?.let { payload.putAll(notificationPayload(it)) }
    VFActionType.trendingArticlePressed ->
      action?.trendingPressedAction?.let {
        payload["containerId"] = it.containerId
        it.articleMetadata?.url?.toString()?.let { url -> payload["articleUrl"] = url }
      }
    VFActionType.openProfilePressed ->
      action?.openProfileAction?.let {
        payload["userUUID"] = it.userUUID.toString()
        payload["presentationType"] =
          if (it.presentationType == VFProfilePresentationType.feed) "feed" else "profile"
      }
    else -> {}
  }
  return payload
}

private fun notificationPayload(action: VFNotificationPresentationAction): Map<String, Any> {
  val payload = mutableMapOf<String, Any>("presentationType" to action.notificationPresentationType.toString())
  action.userUUID?.toString()?.let { payload["userUUID"] = it }
  action.contentContainerUUID?.toString()?.let { payload["containerUUID"] = it }
  action.contentUUID?.toString()?.let { payload["contentUUID"] = it }
  action.containerId?.let { payload["containerId"] = it }
  action.articleMetadata?.url?.toString()?.let { payload["articleUrl"] = it }
  action.articleMetadata?.title?.let { payload["articleTitle"] = it }
  action.url?.let { payload["url"] = it }
  return payload
}
