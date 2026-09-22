package com.viafoura.reactnative

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
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
    enableLogging: Boolean?,
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
          enableLogging?.let { ViafouraSDK.isLoggingEnabled = it }
          return@synchronized
        }

        enableLogging?.let { ViafouraSDK.isLoggingEnabled = it }
        ViafouraSDK.initialize(context, siteUUID, siteDomain)
        initializedKey = initKey
      }
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("E_VF_INIT", e.message ?: "Viafoura initialization failed", e)
    }
  }
}
