platform :ios, '10.3'
use_frameworks!

target 'MovieLab' do
	pod 'MagicalRecord'
	pod 'RestKit'
	pod 'RxSwift'
  pod 'RxRelay'
  pod 'RxCocoa'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end

