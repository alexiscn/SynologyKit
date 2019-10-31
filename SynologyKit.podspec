Pod::Spec.new do |s|
  s.name         = 'SynologyKit'
  s.version      = '0.0.1'
  s.license = 'MIT'
  s.requires_arc = true
  s.source = {:path => 'DevelopmentPods/SynologyKit'}

  s.summary = 'SynologyKit'
  s.homepage = 'SynologyKit'
  s.author       = { 'xushuifeng' => 'https://github.com/alexiscn' }
  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.source_files = 'Source/*.swift'
  
  s.dependency 'Alamofire'
end
