Pod::Spec.new do |s|
  s.name         = 'SynologyKit'
  s.version      = '0.1.2'
  s.license      = 'MIT'
  s.requires_arc = true
#  s.swift_versions = '5.0'
  s.source = { :git => 'https://github.com/alexiscn/SynologyKit.git', :tag => s.version.to_s }

  s.summary = 'Synology File Station SDK for Swift'
  s.homepage = 'https://github.com/alexiscn/SynologyKit'
  s.author       = { 'xushuifeng' => 'https://github.com/alexiscn' }
  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.source_files = 'Source/*.swift'
  
  s.dependency 'Alamofire'
end
