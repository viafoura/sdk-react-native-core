package expo.modules.viafourasdk

import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import java.net.URL

// Viafoura SDK imports. Ensure the SDK is added to the app.
import com.viafourasdk.src.ViafouraSDK
import com.viafourasdk.src.model.network.authentication.cookieLogin.CookieLoginResponse
import com.viafourasdk.src.model.network.authentication.login.LoginResponse
import com.viafourasdk.src.model.network.authentication.loginradius.LoginRadiusLoginResponse
import com.viafourasdk.src.model.network.authentication.openId.OpenIdLoginResponse
import com.viafourasdk.src.model.network.authentication.signup.SignUpResponse
import com.viafourasdk.src.model.network.authentication.socialLogin.SocialLoginResponse
import com.viafourasdk.src.model.network.error.NetworkError
import com.viafourasdk.src.services.auth.VFAuthService

class ViafouraModule : Module() {
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  override fun definition() = ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('Viafoura')` in JavaScript.
    Name("Viafoura")

    // MARK: - Auth API
    AsyncFunction("logout") {
      ViafouraSDK.auth().logout()
    }

    AsyncFunction("login") { email: String, password: String, promise: Promise ->
      ViafouraSDK.auth().login(email, password, object : VFAuthService.LoginCallback {
        override fun onSuccess(loginResponse: LoginResponse) {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_LOGIN", err.message ?: "Login failed", null)
        }
      })
    }

    AsyncFunction("signup") { name: String, email: String, password: String, promise: Promise ->
      ViafouraSDK.auth().signup(name, email, password, object : VFAuthService.SignUpCallback {
        override fun onSuccess(loginResponse: SignUpResponse) {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_SIGNUP", err.message ?: "Signup failed", null)
        }
      })
    }

    // Provider parameter is optional on Android SDK; ignored if provided
    AsyncFunction("socialLogin") { token: String, provider: String?, promise: Promise ->
      ViafouraSDK.auth().socialLogin(token, object : VFAuthService.SocialLoginCallback {
        override fun onSuccess(loginResponse: SocialLoginResponse) {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_SOCIAL", err.message ?: "Social login failed", null)
        }
      })
    }

    AsyncFunction("loginRadiusLogin") { token: String, provider: String?, promise: Promise ->
      ViafouraSDK.auth().loginRadiusLogin(token, object : VFAuthService.LoginRadiusLoginCallback {
        override fun onSuccess(loginResponse: LoginRadiusLoginResponse) {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_LOGINRADIUS", err.message ?: "LoginRadius login failed", null)
        }
      })
    }

    AsyncFunction("openIdLogin") { token: String, promise: Promise ->
      ViafouraSDK.auth().openIdLogin(token, object : VFAuthService.OpenIdLoginCallback {
        override fun onSuccess(loginResponse: OpenIdLoginResponse) {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_OPENID", err.message ?: "OpenID login failed", null)
        }
      })
    }

    AsyncFunction("cookieLogin") { token: String, promise: Promise ->
      ViafouraSDK.auth().cookieLogin(token, object : VFAuthService.CookieLoginCallback {
        override fun onSuccess(loginResponse: CookieLoginResponse) {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_COOKIE", err.message ?: "Cookie login failed", null)
        }
      })
    }

    AsyncFunction("resetPassword") { email: String, promise: Promise ->
      ViafouraSDK.auth().passwordReset(email, object : VFAuthService.PasswordResetCallback {
        override fun onSuccess() {
          promise.resolve(null)
        }
        override fun onError(err: NetworkError) {
          promise.reject("E_VF_RESET", err.message ?: "Password reset failed", null)
        }
      })
    }

    // MARK: - Core API
    AsyncFunction("initialize") { siteUUID: String, siteDomain: String, enableLogging: Boolean?, promise: Promise ->
      val context = appContext.reactContext?.applicationContext
        ?: appContext.currentActivity?.applicationContext
      if (context == null) {
        promise.reject("E_VF_INIT", "No application context available", null)
        return@AsyncFunction
      }
      if (siteUUID.isBlank() || siteDomain.isBlank()) {
        promise.reject("E_VF_INIT", "Invalid Viafoura initialization parameters", null)
        return@AsyncFunction
      }
      try {
        enableLogging?.let { ViafouraSDK.isLoggingEnabled = it }
        ViafouraSDK.initialize(context, siteUUID, siteDomain)
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("E_VF_INIT", e.message ?: "Viafoura initialization failed", e)
      }
    }

    // No additional native view here. PreviewComments is exposed via a separate module.
  }
}
