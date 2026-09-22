require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'Viafoura'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios
  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.5', '5.6', '5.7', '5.8', '5.9']
  s.source         = { git: 'https://github.com/viafoura/sdk-react-native-core' }
  s.static_framework = true

  s.dependency 'React-Core'
  s.ios.vendored_frameworks = 'ios/ViafouraSDK.xcframework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  s.source_files = 'ios/*.{h,m,mm,swift}'
  s.exclude_files = 'ios/ViafouraSDK.xcframework/**/*'
end
