package com.viafoura.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import java.net.URL
import java.util.Locale
import java.util.UUID

import com.viafourasdk.src.ViafouraSDK
import com.viafourasdk.src.model.network.authentication.cookieLogin.CookieLoginResponse
import com.viafourasdk.src.model.network.authentication.login.LoginResponse
import com.viafourasdk.src.model.network.authentication.loginradius.LoginRadiusLoginResponse
import com.viafourasdk.src.model.network.authentication.openId.OpenIdLoginResponse
import com.viafourasdk.src.model.network.authentication.signup.SignUpResponse
import com.viafourasdk.src.model.network.authentication.socialLogin.SocialLoginResponse
import com.viafourasdk.src.model.network.error.NetworkError
import com.viafourasdk.src.services.auth.VFAuthService
import com.viafourasdk.src.model.local.VFTrendingSortType
import com.viafourasdk.src.model.network.comments.trending.TrendingResponse
import com.viafourasdk.src.model.network.authentication.UserResponse
import com.viafourasdk.src.model.network.comments.commentsProfile.CommentsProfileResponse
import com.viafourasdk.src.model.network.comments.fetchComments.CommentsListResponse
import com.viafourasdk.src.model.network.notifications.notifications.AllNotificationsResponse
import com.viafourasdk.src.model.network.notifications.users.SubscriptionResponse
import com.viafourasdk.src.model.network.notifications.users.UserSubscribeResponse
import com.viafourasdk.src.model.network.notifications.users.UserSubscribersResponse
import com.viafourasdk.src.model.network.notifications.users.UserSubscriptionsResponse
import com.viafourasdk.src.services.liveComments.VFLiveCommentsService
import com.viafourasdk.src.services.notifications.VFNotificationsService
import com.viafourasdk.src.services.users.VFUsersService

class ViafouraModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  companion object {
    const val NAME = "Viafoura"

    private val initLock = Any()
    private var initializedKey: String? = null

    private fun initializationKey(siteUUID: String, siteDomain: String): String? {
      val trimmedSiteUUID = siteUUID.trim()
      val trimmedSiteDomain = siteDomain.trim()

      if (trimmedSiteDomain.isBlank()) {
        return null
      }

      val normalizedUUID = try {
        UUID.fromString(trimmedSiteUUID).toString().lowercase(Locale.ROOT)
      } catch (e: IllegalArgumentException) {
        return null
      }

      return "$normalizedUUID::${normalizeSiteDomain(trimmedSiteDomain)}"
    }

    private fun normalizeSiteDomain(value: String): String {
      val host = try {
        URL(value).host
      } catch (e: Exception) {
        null
      }

      return (if (host.isNullOrBlank()) value else host).lowercase(Locale.ROOT)
    }
  }

  override fun getName(): String = NAME

  @ReactMethod
  fun logout(promise: Promise) {
    ViafouraSDK.auth().logout()
    promise.resolve(null)
  }

  @ReactMethod
  fun login(email: String, password: String, promise: Promise) {
    ViafouraSDK.auth().login(email, password, object : VFAuthService.LoginCallback {
      override fun onSuccess(loginResponse: LoginResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_LOGIN", err.message ?: "Login failed", null)
      }
    })
  }

  @ReactMethod
  fun signup(name: String, email: String, password: String, promise: Promise) {
    ViafouraSDK.auth().signup(name, email, password, object : VFAuthService.SignUpCallback {
      override fun onSuccess(loginResponse: SignUpResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_SIGNUP", err.message ?: "Signup failed", null)
      }
    })
  }

  @ReactMethod
  fun socialLogin(token: String, provider: String?, promise: Promise) {
    ViafouraSDK.auth().socialLogin(token, object : VFAuthService.SocialLoginCallback {
      override fun onSuccess(loginResponse: SocialLoginResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_SOCIAL", err.message ?: "Social login failed", null)
      }
    })
  }

  @ReactMethod
  fun loginRadiusLogin(token: String, provider: String?, promise: Promise) {
    ViafouraSDK.auth().loginRadiusLogin(token, object : VFAuthService.LoginRadiusLoginCallback {
      override fun onSuccess(loginResponse: LoginRadiusLoginResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_LOGINRADIUS", err.message ?: "LoginRadius login failed", null)
      }
    })
  }

  @ReactMethod
  fun openIdLogin(token: String, promise: Promise) {
    ViafouraSDK.auth().openIdLogin(token, object : VFAuthService.OpenIdLoginCallback {
      override fun onSuccess(loginResponse: OpenIdLoginResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_OPENID", err.message ?: "OpenID login failed", null)
      }
    })
  }

  @ReactMethod
  fun cookieLogin(token: String, promise: Promise) {
    ViafouraSDK.auth().cookieLogin(token, object : VFAuthService.CookieLoginCallback {
      override fun onSuccess(loginResponse: CookieLoginResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_COOKIE", err.message ?: "Cookie login failed", null)
      }
    })
  }

  @ReactMethod
  fun getUserLoginStatus(promise: Promise) {
    ViafouraSDK.auth().getUserLoginStatus { userIsLoggedIn, userUUID ->
      val status = Arguments.createMap()
      status.putBoolean("isLoggedIn", userIsLoggedIn)
      userUUID?.let { status.putString("userUUID", it) }
      promise.resolve(status)
    }
  }

  @ReactMethod
  fun resetPassword(email: String, promise: Promise) {
    ViafouraSDK.auth().passwordReset(email, object : VFAuthService.PasswordResetCallback {
      override fun onSuccess() {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_RESET", err.message ?: "Password reset failed", null)
      }
    })
  }

  @ReactMethod
  fun initialize(
    siteUUID: String,
    siteDomain: String,
    enableLogging: Boolean,
    promise: Promise
  ) {
    val context = reactContext.applicationContext
    if (context == null) {
      promise.reject("E_VF_INIT", "No application context available", null)
      return
    }
    if (siteUUID.isBlank() || siteDomain.isBlank()) {
      promise.reject("E_VF_INIT", "Invalid Viafoura initialization parameters", null)
      return
    }
    val initKey = initializationKey(siteUUID, siteDomain)
    if (initKey == null) {
      promise.reject("E_VF_INIT", "Invalid Viafoura initialization parameters", null)
      return
    }
    try {
      synchronized(initLock) {
        val currentKey = initializedKey
        if (currentKey != null) {
          if (currentKey != initKey) {
            throw IllegalStateException("ViafouraSDK is already initialized with a different site")
          }
          ViafouraSDK.isLoggingEnabled = enableLogging
          return@synchronized
        }

        ViafouraSDK.isLoggingEnabled = enableLogging
        ViafouraSDK.initialize(context, siteUUID, siteDomain)
        initializedKey = initKey
      }
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("E_VF_INIT", e.message ?: "Viafoura initialization failed", e)
    }
  }

  @ReactMethod
  fun setDataTrackingEnabled(enabled: Boolean, promise: Promise) {
    ViafouraSDK.setDataTrackingEnabled(enabled)
    promise.resolve(null)
  }

  @ReactMethod
  fun getCommentCount(containerId: String, syndicationKey: String?, promise: Promise) {
    if (containerId.isBlank()) {
      promise.reject("E_VF_COMMENT_COUNT", "Invalid Viafoura container id", null)
      return
    }
    val siteUUID = try {
      UUID.fromString(ViafouraSDK.siteUUID)
    } catch (e: Exception) {
      promise.reject("E_VF_COMMENT_COUNT", "ViafouraSDK is not initialized", null)
      return
    }
    ViafouraSDK.liveComments().getCommentCount(
      siteUUID,
      containerId,
      syndicationKey,
      object : VFLiveCommentsService.CommentCountCallback {
        override fun onSuccess(commentCount: Int?) {
          promise.resolve(commentCount ?: 0)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_COMMENT_COUNT", err.message ?: "Comment count failed", null)
        }
      }
    )
  }

  @ReactMethod
  fun getTrendingArticles(limit: Int, trendWindow: Int, daysPublished: Int?, promise: Promise) {
    val siteUUID = try {
      UUID.fromString(ViafouraSDK.siteUUID)
    } catch (e: Exception) {
      promise.reject("E_VF_TRENDING", "ViafouraSDK is not initialized", null)
      return
    }
    ViafouraSDK.liveComments().getTrendingContent(
      siteUUID,
      limit,
      daysPublished,
      trendWindow,
      VFTrendingSortType.comments,
      object : VFLiveCommentsService.TrendingContentCallback {
        override fun onSuccess(trendingResponse: TrendingResponse) {
          val articles = Arguments.createArray()
          trendingResponse.trending.orEmpty().forEach { article ->
            val map = Arguments.createMap()
            map.putString("containerId", article.containerId)
            map.putString("contentContainerUUID", article.contentContainerUUID)
            map.putString("title", article.originTitle)
            map.putString("url", article.originUrl)
            map.putInt("commentCount", article.totalVisibleContents?.toInt() ?: 0)
            map.putDouble("datePublished", article.datePublished?.toDouble() ?: 0.0)
            article.originSummary?.let { map.putString("summary", it) }
            article.originImageUrl?.let { map.putString("imageUrl", it) }
            articles.pushMap(map)
          }
          promise.resolve(articles)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_TRENDING", err.message ?: "Trending articles failed", null)
        }
      }
    )
  }

  private fun parseUUID(value: String?, code: String, promise: Promise): UUID? {
    return try {
      UUID.fromString(value?.trim())
    } catch (e: Exception) {
      promise.reject(code, "Invalid UUID: $value", null)
      null
    }
  }

  private fun parseUUIDs(values: ReadableArray, code: String, promise: Promise): List<UUID>? {
    val uuids = ArrayList<UUID>(values.size())
    for (i in 0 until values.size()) {
      uuids.add(parseUUID(values.getString(i), code, promise) ?: return null)
    }
    return uuids
  }

  private fun siteUUID(code: String, promise: Promise): UUID? {
    return try {
      UUID.fromString(ViafouraSDK.siteUUID)
    } catch (e: Exception) {
      promise.reject(code, "ViafouraSDK is not initialized", null)
      null
    }
  }

  private fun followPage(total: Int?, hasMore: Boolean?, subscriptions: List<SubscriptionResponse>?): WritableMap {
    val users = Arguments.createArray()
    subscriptions.orEmpty().forEach { subscription ->
      val user = Arguments.createMap()
      user.putString("userUUID", subscription.userUUID)
      user.putString("subscriptionUUID", subscription.subscriptionUUID)
      user.putDouble("dateCreated", subscription.dateCreated?.toDouble() ?: 0.0)
      users.pushMap(user)
    }
    val page = Arguments.createMap()
    page.putInt("total", total ?: 0)
    page.putBoolean("hasMore", hasMore ?: false)
    page.putArray("users", users)
    return page
  }

  @ReactMethod
  fun getNewNotificationCount(promise: Promise) {
    ViafouraSDK.notifications().getNewNotificationCount(object : VFNotificationsService.NewNotificationCountCallback {
      override fun onSuccess(count: Int) {
        promise.resolve(count)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_NOTIFICATIONS", err.message ?: "Notification count failed", null)
      }
    })
  }

  @ReactMethod
  fun getNotifications(promise: Promise) {
    ViafouraSDK.notifications().getUserNotifications(object : VFNotificationsService.UserNotificationsCallback {
      override fun onSuccess(allNotificationsResponse: AllNotificationsResponse) {
        val notifications = Arguments.createArray()
        allNotificationsResponse.notifications.orEmpty().forEach { notification ->
          val events = Arguments.createArray()
          notification.notifications.orEmpty().forEach { payload ->
            val event = Arguments.createMap()
            event.putString("notificationUUID", payload.notificationUUID)
            event.putString("actorUUID", payload.actorUUID)
            event.putString("actorType", payload.actorType)
            event.putString("contentUUID", payload.contentUUID)
            event.putString("status", payload.status)
            event.putDouble("time", payload.time?.toDouble() ?: 0.0)
            events.pushMap(event)
          }
          val map = Arguments.createMap()
          map.putDouble("groupingKey", notification.grouping_key?.toDouble() ?: 0.0)
          // Gson leaves an enum null when the API sends a type this SDK version does not know.
          map.putString("type", notification.notificationType?.name ?: "unknown")
          map.putString("serviceType", notification.service_type?.name ?: "unknown")
          map.putString("targetUUID", notification.targetUUID)
          map.putString("threadUUID", notification.threadUUID)
          map.putString("contentContainerUUID", notification.contentContainerUUID)
          map.putString("sectionUUID", notification.sectionUUID)
          map.putArray("events", events)
          notifications.pushMap(map)
        }
        val broadcasts = Arguments.createArray()
        allNotificationsResponse.broadcasts.orEmpty().forEach { broadcast ->
          val map = Arguments.createMap()
          map.putString("notificationUUID", broadcast.notificationUUID)
          map.putString("sectionUUID", broadcast.sectionUUID)
          map.putString("actorUUID", broadcast.actorUUID)
          map.putString("type", broadcast.notificatioType?.name ?: "unknown")
          map.putString("status", broadcast.status)
          map.putDouble("time", broadcast.time?.toDouble() ?: 0.0)
          map.putString("title", broadcast.target_title)
          map.putString("description", broadcast.target_description)
          map.putString("url", broadcast.target_url)
          broadcast.target_image_url?.let { map.putString("imageUrl", it) }
          map.putString("topicId", broadcast.target_topic_id)
          broadcasts.pushMap(map)
        }
        val result = Arguments.createMap()
        result.putArray("notifications", notifications)
        result.putArray("broadcasts", broadcasts)
        promise.resolve(result)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_NOTIFICATIONS", err.message ?: "Notifications failed", null)
      }
    })
  }

  @ReactMethod
  fun markNotificationsRead(notificationUUIDs: ReadableArray, promise: Promise) {
    val uuids = parseUUIDs(notificationUUIDs, "E_VF_NOTIFICATIONS", promise) ?: return
    ViafouraSDK.notifications().markNotificationsRead(uuids, object : VFNotificationsService.NotificationReadCallback {
      override fun onSuccess() {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_NOTIFICATIONS", err.message ?: "Marking notifications read failed", null)
      }
    })
  }

  @ReactMethod
  fun markNotificationsSeen(notificationUUIDs: ReadableArray, promise: Promise) {
    val uuids = parseUUIDs(notificationUUIDs, "E_VF_NOTIFICATIONS", promise) ?: return
    ViafouraSDK.notifications().markNotificationsSeen(uuids, object : VFNotificationsService.NotificationSeenCallback {
      override fun onSuccess() {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_NOTIFICATIONS", err.message ?: "Marking notifications seen failed", null)
      }
    })
  }

  @ReactMethod
  fun removeNotifications(notificationUUIDs: ReadableArray, promise: Promise) {
    val uuids = parseUUIDs(notificationUUIDs, "E_VF_NOTIFICATIONS", promise) ?: return
    ViafouraSDK.notifications().deleteNotifications(uuids, object : VFNotificationsService.DeleteNotificationCallback {
      override fun onSuccess() {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_NOTIFICATIONS", err.message ?: "Removing notifications failed", null)
      }
    })
  }

  @ReactMethod
  fun getFollowers(page: Int?, promise: Promise) {
    ViafouraSDK.notifications().getUserSubscribers(page, object : VFNotificationsService.UserSubscribersCallback {
      override fun onSuccess(userSubscriptionsResponse: UserSubscribersResponse) {
        promise.resolve(followPage(userSubscriptionsResponse.total, userSubscriptionsResponse.hasMore, userSubscriptionsResponse.subscriptions))
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_FOLLOW", err.message ?: "Followers failed", null)
      }
    })
  }

  @ReactMethod
  fun getFollowing(page: Int?, promise: Promise) {
    ViafouraSDK.notifications().getUserSubscriptions(page, object : VFNotificationsService.UserSubscriptionsCallback {
      override fun onSuccess(userSubscriptionsResponse: UserSubscriptionsResponse) {
        promise.resolve(followPage(userSubscriptionsResponse.total, userSubscriptionsResponse.hasMore, userSubscriptionsResponse.subscriptions))
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_FOLLOW", err.message ?: "Following failed", null)
      }
    })
  }

  @ReactMethod
  fun getFollowerCount(userUUID: String, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_FOLLOW", promise) ?: return
    ViafouraSDK.notifications().getSubscribersCount(uuid, object : VFNotificationsService.SubscribersCountCallback {
      override fun onSuccess(total: Int) {
        promise.resolve(total)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_FOLLOW", err.message ?: "Follower count failed", null)
      }
    })
  }

  @ReactMethod
  fun isFollowingUser(userUUID: String, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_FOLLOW", promise) ?: return
    ViafouraSDK.notifications().isSubscribedToUser(uuid, object : VFNotificationsService.UserSubscribedCallback {
      override fun onSuccess(subscribed: Boolean) {
        promise.resolve(subscribed)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_FOLLOW", err.message ?: "Follow state failed", null)
      }
    })
  }

  @ReactMethod
  fun followUser(userUUID: String, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_FOLLOW", promise) ?: return
    ViafouraSDK.notifications().subscribeToUser(uuid, object : VFNotificationsService.UserSubscribeCallback {
      override fun onSuccess(userSubscribeResponse: UserSubscribeResponse) {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_FOLLOW", err.message ?: "Follow failed", null)
      }
    })
  }

  @ReactMethod
  fun unfollowUser(userUUID: String, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_FOLLOW", promise) ?: return
    ViafouraSDK.notifications().unsuscribeFromUser(uuid, object : VFNotificationsService.UserUnsuscribeCallback {
      override fun onSuccess() {
        promise.resolve(null)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_FOLLOW", err.message ?: "Unfollow failed", null)
      }
    })
  }

  @ReactMethod
  fun getUserInfo(userUUID: String, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_USER", promise) ?: return
    ViafouraSDK.users().getUserInfo(uuid, object : VFUsersService.UserInfoCallback {
      override fun onSuccess(userResponse: UserResponse) {
        val user = Arguments.createMap()
        user.putString("userUUID", userResponse.uuid ?: userUUID)
        user.putString("name", userResponse.name ?: "")
        userResponse.picLarge?.let { user.putString("avatarUrl", it) }
        userResponse.picSmall?.let { user.putString("avatarSmallUrl", it) }
        promise.resolve(user)
      }
      override fun onError(err: NetworkError) {
        promise.reject("E_VF_USER", err.message ?: "User info failed", null)
      }
    })
  }

  @ReactMethod
  fun getUserComments(userUUID: String, limit: Int, startingFrom: String?, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_USER_COMMENTS", promise) ?: return
    val site = siteUUID("E_VF_USER_COMMENTS", promise) ?: return
    ViafouraSDK.liveComments().getUserComments(
      site,
      uuid,
      limit,
      startingFrom,
      object : VFLiveCommentsService.GetUserCommentsCallback {
        override fun onSuccess(commentsListResponse: CommentsListResponse) {
          val contents = commentsListResponse.contents.orEmpty()
          val comments = Arguments.createArray()
          contents.forEach { comment ->
            val map = Arguments.createMap()
            map.putString("contentUUID", comment.contentUUID)
            map.putString("contentContainerUUID", comment.contentContainerUUID)
            map.putString("threadUUID", comment.threadUUID)
            map.putString("content", comment.content ?: "")
            map.putDouble("dateCreated", comment.dateCreated?.toDouble() ?: 0.0)
            map.putDouble("totalLikes", comment.totalLikes?.toDouble() ?: 0.0)
            map.putDouble("totalReplies", comment.totalReplies?.toDouble() ?: 0.0)
            comments.pushMap(map)
          }
          val page = Arguments.createMap()
          page.putArray("comments", comments)
          page.putBoolean("moreAvailable", commentsListResponse.moreAvailable ?: false)
          contents.lastOrNull()?.contentUUID?.let { page.putString("nextCursor", it) }
          promise.resolve(page)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_USER_COMMENTS", err.message ?: "User comments failed", null)
        }
      }
    )
  }

  @ReactMethod
  fun getUserStats(userUUID: String, promise: Promise) {
    val uuid = parseUUID(userUUID, "E_VF_USER_STATS", promise) ?: return
    val site = siteUUID("E_VF_USER_STATS", promise) ?: return
    ViafouraSDK.liveComments().getCommentsProfile(
      site,
      uuid.toString(),
      object : VFLiveCommentsService.CommentsProfileCallback {
        override fun onSuccess(commentsProfileResponse: CommentsProfileResponse) {
          val stats = Arguments.createMap()
          stats.putInt("contentCreated", commentsProfileResponse.contentCreated ?: 0)
          stats.putInt("likesReceived", commentsProfileResponse.likesReceived ?: 0)
          stats.putInt("likesCreated", commentsProfileResponse.likesCreated ?: 0)
          stats.putInt("dislikesReceived", commentsProfileResponse.dislikesReceived ?: 0)
          stats.putInt("dislikesCreated", commentsProfileResponse.dislikesCreated ?: 0)
          promise.resolve(stats)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_USER_STATS", err.message ?: "User stats failed", null)
        }
      }
    )
  }
}
