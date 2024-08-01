source "https://github.com/Ogury/ogury-cocoapods-repository.git"
source 'https://cdn.cocoapods.org/'


plugin 'cocoapods-art', :sources => [
  'sdk-cocoapods-prod',
]


platform :ios, "12.0"
use_frameworks!
workspace "OgurySdks.xcworkspace"

install! 'cocoapods',:warn_for_multiple_pod_sources => false, :warn_for_unused_master_specs_repo => false

target 'LegacyTestApp' do
  project 'sdk-ads-ios/LegacyTestApp/LegacyTestApp'
  pod 'RxSwift', "6.2.0" # 6.5+ introduced concurrency supports which breaks with iOS under 13
  pod 'RxCocoa', "6.2.0" # 6.5+ introduced concurrency supports which breaks with iOS under 13
  pod 'Yaml'
  pod 'DDPopoverBackgroundView'
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
  pod "SnapKit"
end

#Ads
target "OguryAds-Release" do
  project "sdk-ads-ios/OguryAdsSDK"

  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end

target "OguryCoreTests" do
  project "sdk-core-ios/OguryCore"
  pod "OCMock", :git=> 'https://github.com/SDKOguryDev/ocmock', :branch => 'master'
end

target "OguryAdsTests" do
  project "sdk-ads-ios/OguryAdsSDK"

  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
  pod "OCMock", :git=> 'https://github.com/SDKOguryDev/ocmock', :branch => 'master'
end

target "AdsCardLibrary-Release" do
  project "sdk-ads-ios/AdsCardLibrary/AdsCardLibrary"
  pod "OguryAds-Prod", "3.7.0-rc-3"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end

#Ads Test Apps
target "AdsTestApp-Devc" do
  project "sdk-ads-ios/AdsTestApp/AdsTestApp"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end
target "AdsTestApp-Staging" do
  project "sdk-ads-ios/AdsTestApp/AdsTestApp"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end
target "AdsTestApp-Prod" do
  project "sdk-ads-ios/AdsTestApp/AdsTestApp"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end

target "AdsTestApp-Release-Devc" do
  project "sdk-ads-ios/AdsTestApp/AdsTestApp"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end
target "AdsTestApp-Release-Staging" do
  project "sdk-ads-ios/AdsTestApp/AdsTestApp"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end
target "AdsTestApp-Release-Prod" do
  project "sdk-ads-ios/AdsTestApp/AdsTestApp"
  pod "OguryCore-Prod", "1.4.1-RC-1.0.7"
end


#Wrapper
target 'OguryWrapper' do
  project "sdk-wrapper-ios/OguryWrapper/OguryWrapper.xcodeproj/"
  pod 'OguryCore-Prod', '1.4.1-RC-1.0.7'

  target 'OguryWrapperTests' do
    inherit! :complete

    pod 'OCMock', :git=> 'https://github.com/SDKOguryDev/ocmock', :branch => 'master'
  end
end

target 'OguryWrapperTestApp' do
  project "sdk-wrapper-ios/OguryWrapperTestApp/OguryWrapperTestApp.xcodeproj"
  pod 'OguryCore-Prod', '1.4.1-RC-1.0.7'
  pod 'OguryAds-Prod', '3.7.0-rc-3'
  pod 'OguryChoiceManager-Prod', '4.3.0-rc-2'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "10.0"
    end
  end
end
