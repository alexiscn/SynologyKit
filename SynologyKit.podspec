Pod::Spec.new do |s|
  s.name         = 'SynologyKit'
  s.version      = '1.3.9'
  s.license      = 'MIT'
  s.requires_arc = true
  s.swift_versions = ['5.0', '5.1', '5.1.2']
  s.source = { :git => 'https://github.com/alexiscn/SynologyKit.git', :tag => s.version.to_s }

  s.summary = 'Synology File Station SDK for Swift'
  s.homepage = 'https://github.com/alexiscn/SynologyKit'
  s.author       = { 'xushuifeng' => 'https://github.com/alexiscn' }
  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '12.0'
  s.osx.deployment_target = '10.12'
  s.source_files = 'Source/*.swift'
  
  s.dependency 'Alamofire'
end
