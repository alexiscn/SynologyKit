platform:ios, '11.0'
use_frameworks!

target 'SynologyKitExample' do
  pod 'SnapKit'
  pod 'KeychainSwift'
  pod 'WXActionSheet'
  pod 'Kingfisher'
  pod 'SynologyKit', :path => '.'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
    end
 end
end
