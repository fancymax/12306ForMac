source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.11'

target "12306ForMac" do
use_frameworks!
    pod 'FMDB'
    pod 'SwiftyJSON'
    pod 'PromiseKit', '~> 4.0'
    pod 'Alamofire', '~> 4.0'
    pod 'XCGLogger', '~> 4.0'
    pod 'Fabric'
    pod 'Crashlytics'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            #Configure Pod targets for Xcode 8 compatibility
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
