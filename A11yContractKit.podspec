Pod::Spec.new do |s|
  s.name             = 'A11yContractKit'
  s.version          = '1.1.0'
  s.summary          = 'Developer-first accessibility contract layer for iOS apps'
  s.description      = <<-DESC
    A11yContractKit helps mobile teams define, validate, report, and track
    accessibility requirements from components, tests, and CI pipelines.
  DESC
  s.homepage         = 'https://github.com/giovaninb/a11y-contract-kit'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'giovaninb' => 'https://github.com/giovaninb' }
  s.source           = {
    :git => 'https://github.com/giovaninb/a11y-contract-kit.git',
    :tag => s.version.to_s
  }
  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.9'

  s.subspec 'Core' do |ss|
    ss.source_files  = 'Sources/A11yContractCore/**/*.swift'
    ss.pod_target_xcconfig = { 'PRODUCT_MODULE_NAME' => 'A11yContractCore' }
  end

  s.subspec 'Reporter' do |ss|
    ss.source_files  = 'Sources/A11yContractReporter/**/*.swift'
    ss.dependency    'A11yContractKit/Core'
    ss.pod_target_xcconfig = { 'PRODUCT_MODULE_NAME' => 'A11yContractReporter' }
  end

  s.subspec 'UIKit' do |ss|
    ss.source_files  = 'Sources/A11yContractUIKit/**/*.swift'
    ss.dependency    'A11yContractKit/Core'
    ss.pod_target_xcconfig = { 'PRODUCT_MODULE_NAME' => 'A11yContractUIKit' }
  end

  s.subspec 'SwiftUI' do |ss|
    ss.source_files  = 'Sources/A11yContractSwiftUI/**/*.swift'
    ss.dependency    'A11yContractKit/Core'
    ss.pod_target_xcconfig = { 'PRODUCT_MODULE_NAME' => 'A11yContractSwiftUI' }
  end

  s.subspec 'Testing' do |ss|
    ss.source_files  = 'Sources/A11yContractTesting/**/*.swift'
    ss.dependency    'A11yContractKit/Core'
    ss.dependency    'A11yContractKit/Reporter'
    ss.dependency    'A11yContractKit/UIKit'
    ss.frameworks    = 'XCTest'
    ss.pod_target_xcconfig = { 'PRODUCT_MODULE_NAME' => 'A11yContractTesting' }
  end

  s.default_subspecs = 'UIKit', 'Reporter'
end
