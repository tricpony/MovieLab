platform :ios, '8.1'
use_frameworks!

target 'MovieLab' do
	pod 'MagicalRecord'
	pod 'RestKit'
	pod 'RxSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

