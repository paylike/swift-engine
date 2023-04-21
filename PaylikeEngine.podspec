Pod::Spec.new do |s|
  s.name             = 'PaylikeEngine'
  s.swift_version    = '5.0'
  s.ios.deployment_target = '13.0'
  s.version          = '0.1.0'
  s.summary          = 'This library includes the core elements required to implement a payment flow towards the Paylike API.
  s.description      = <<-DESC
This packages is a clone of the JS version and responsible for providing a hand high level interface to create payments in the Paylike ecosystem
                        DESC
                                                                
  s.homepage         = 'https://github.com/paylike/swift-engine'
  s.license          = { :type => 'BSD-3', :file => 'LICENSE' }
  s.author           = { 'Paylike.io' => 'info@paylike.io' }
  s.source           = {
      :git => 'https://github.com/paylike/swift-engine.git',
      :tag => s.version.to_s
  }
  s.source_files = 'Sources/PaylikeEngine/**/*'
  s.dependency 'PaylikeLuhn'
  s.dependency 'PaylikeClient'
end
