platform :ios, '16.0'
use_frameworks!

project 'SPPB.xcodeproj'


pod 'GoogleMLKit/PoseDetection', '4.0.0'
pod 'GoogleMLKit/PoseDetectionAccurate', '4.0.0'

target 'SPPB' do
end

# Disable signing for pods
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
         end
    end
  end
end
