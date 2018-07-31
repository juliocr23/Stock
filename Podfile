# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Stock' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Stock

pod 'Alamofire'
pod 'SVProgressHUD'
pod 'SwiftyJSON'

pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git', :branch => 'master'
pod 'RealmSwift', '~> 3.7.1'
pod 'SwiftSoup'
pod 'Firebase'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'SVProgressHUD'
pod 'ChameleonFramework'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end

