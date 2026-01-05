require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'Viafoura'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  # Support iOS only; ViafouraCore is iOS-only. Keep a reasonable minimum.
  s.platform       = :ios
  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.5', '5.6', '5.7', '5.8', '5.9']
  s.source         = { git: 'https://github.com/viafoura/sdk-react-native' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'
  # Add Viafoura iOS SDK (CocoaPods pod name is ViafouraCore, Swift module is ViafouraSDK)
  s.dependency 'ViafouraCore'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
end
