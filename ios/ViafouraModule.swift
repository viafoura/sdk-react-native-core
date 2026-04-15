import ExpoModulesCore

// Optional Viafoura SDK import. Code is guarded to build without it.
#if canImport(ViafouraSDK)
import ViafouraSDK

enum VFAdapterError: Error, LocalizedError {
  case invalidProvider
  case invalidInitialization

  var errorDescription: String? {
    switch self {
    case .invalidProvider:
      return "Invalid social login provider"
    case .invalidInitialization:
      return "Invalid Viafoura initialization parameters"
    }
  }
}

struct VFAuthAdapter {
  private let authService = ViafouraSDK.auth()

  func logout() {
    authService.logout()
  }

  func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.login(email: email, password: password) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func signup(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.signup(name: name, email: email, password: password, recaptchaToken: nil) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func socialLogin(token: String, provider: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let p = VFSocialLoginProvider(rawValue: provider) else {
      completion(.failure(VFAdapterError.invalidProvider))
      return
    }
    authService.socialLogin(token: token, provider: p) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func loginRadiusLogin(token: String, provider: String?, completion: @escaping (Result<Void, Error>) -> Void) {
    let p: VFSocialLoginProvider
    if let provider, !provider.isEmpty {
      guard let parsed = VFSocialLoginProvider(rawValue: provider) else {
        completion(.failure(VFAdapterError.invalidProvider))
        return
      }
      p = parsed
    } else {
      p = .none
    }

    authService.loginRadiusLogin(token: token, provider: p) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func openIdLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.openIdLogin(token: token) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func cookieLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.cookieLogin(token: token) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
    authService.resetPassword(email: email) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

struct VFCoreAdapter {
  func initialize(siteUUID: String, siteDomain: String, enableLogging: Bool?) {
    if let enableLogging {
      ViafouraSDK.setLoggingEnabled(enableLogging)
    }
    ViafouraSDK.initialize(siteUUID: siteUUID, siteDomain: siteDomain)
  }
}

#else

enum VFAdapterError: Error, LocalizedError {
  case sdkUnavailable
  case invalidProvider
  case invalidInitialization

  var errorDescription: String? {
    switch self {
    case .sdkUnavailable:
      return "ViafouraSDK is not installed. Add the iOS SDK to enable auth."
    case .invalidProvider:
      return "Invalid social login provider"
    case .invalidInitialization:
      return "Invalid Viafoura initialization parameters"
    }
  }
}

struct VFAuthAdapter {
  func logout() { /* no-op when SDK unavailable */ }

  func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func signup(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func socialLogin(token: String, provider: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func openIdLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func cookieLogin(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }

  func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
    completion(.failure(VFAdapterError.sdkUnavailable))
  }
}

struct VFCoreAdapter {
  func initialize(siteUUID: String, siteDomain: String, enableLogging: Bool?) {
    // no-op
  }
}

#endif

public class ViafouraModule: Module {
  private let auth = VFAuthAdapter()
  private let core = VFCoreAdapter()

  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('Viafoura')` in JavaScript.
    Name("Viafoura")

    // Defines constant property on the module.
    Constant("PI") {
      Double.pi
    }

    // Defines event names that the module can send to JavaScript.
    Events("onChange")

    // MARK: - Auth API
    AsyncFunction("logout") {
      self.auth.logout()
    }

    AsyncFunction("login") { (email: String, password: String) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        self.auth.login(email: email, password: password) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    AsyncFunction("signup") { (name: String, email: String, password: String) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        self.auth.signup(name: name, email: email, password: password) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    AsyncFunction("socialLogin") { (token: String, provider: String?) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        guard let provider = provider, !provider.isEmpty else {
          continuation.resume(throwing: VFAdapterError.invalidProvider)
          return
        }
        self.auth.socialLogin(token: token, provider: provider) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    AsyncFunction("loginRadiusLogin") { (token: String, provider: String?) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        self.auth.loginRadiusLogin(token: token, provider: provider) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    AsyncFunction("openIdLogin") { (token: String) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        self.auth.openIdLogin(token: token) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    AsyncFunction("cookieLogin") { (token: String) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        self.auth.cookieLogin(token: token) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    AsyncFunction("resetPassword") { (email: String) async throws in
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        self.auth.resetPassword(email: email) { result in
          switch result {
          case .success:
            continuation.resume()
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }

    // MARK: - Core API
    AsyncFunction("initialize") { (siteUUID: String, siteDomain: String, enableLogging: Bool?) async throws in
      guard !siteUUID.isEmpty, !siteDomain.isEmpty else {
        throw VFAdapterError.invalidInitialization
      }
      self.core.initialize(siteUUID: siteUUID, siteDomain: siteDomain, enableLogging: enableLogging)
    }

    // No additional native view here. PreviewComments is exposed via a separate module.
  }
}
