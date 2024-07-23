class Configuration
  attr_reader :workspace, :targets, :schemes, :sdks, :test_devices, :allowed_environments, :firebase, :artifactory, :amazon, :slack, :cocoapods, :frameworks, :directories

  def initialize
    @workspace = Workspace.new("OgurySdks", "OgurySdks.xcworkspace")
    ads = Target.new("OguryAds", "sdk-ads-ios/OguryAdsSDK.xcodeproj", "OguryAds")
    adsLibrary = Target.new("AdsCardLibrary", "sdk-ads-ios/OguryAdsSDK.xcodeproj", "AdsCardLibrary")
    core = Target.new("OguryCore", "sdk-core-ios/OguryCore.xcodeproj", "OguryCore")
    wrapper = Target.new("OguryWrapper", "sdk-wrapper-ios/OguryWrapper/OguryWrapper.xcodeproj", "OguryWrapper", "OgurySdk")
    testApp = Target.new("OguryCore", "sdk-core-ios/OguryCore.xcodeproj", "OguryCore")
    @targets = Targets.new(ads, adsLibrary, core, wrapper)
    @sdks = Sdks.new(["iphoneos", "iphonesimulator"], ["iphonesimulator"])
    @test_devices = ["iPhone 15"]
    @allowed_environments = ["devc", "staging", "prod", "beta", "release"]
    @firebase = Firebase.new("sdk-tester-group")
    @artifactory = Artifactory.new("https://ogury.jfrog.io/artifactory")
    @amazon = Amazon.new("https://binaries.ogury.co", "ads-ios")
    @slack = Slack.new("https://hooks.slack.com/services/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", "#sdk-ios-ci-update")
    @cocoapods = Cocoapods.new("git@github.com:Ogury/ogury-cocoapods-repository.git")
    @frameworks = Frameworks.new("./OMSDK_Ogury.xcframework")
    @frameworks.ogury_core = Framework.new("1.4.1-RC-1.0.7", "1.4.0", "1.4.1")
    @frameworks.ogury_ads = Framework.new("3.7.0-rc-3", "3.7.0-rc-3", "3.7.0")
    @frameworks.ogury_choice_manager = Framework.new("4.3.0-rc-2", "4.1.0-beta-1.0.0", "4.3.0")
    @directories = Directories.new("./jenkins/build", "./jenkins/output", "./jenkins/test_derived_data", "./jenkins/testApp")
  end
end

Workspace = Struct.new(:name, :file_path) do
end

Targets = Struct.new(:ads, :adsLibrary, :core, :wrapper, :testApp) do
end

Target = Struct.new(:name, :path, :scheme, :releaseScheme, :publicName) do
  def initialize(name, path, scheme, releaseScheme = nil, publicName = nil)
    publicName ||= name
    releaseScheme ||= "#{scheme}-Release"
    super(name, path, scheme, releaseScheme, publicName)
  end
end

Sdks = Struct.new(:defaults, :tests) do
end

Firebase = Struct.new(:test_group) do
end

Artifactory = Struct.new(:url) do
end

Amazon = Struct.new(:url, :project_key) do
end

Slack = Struct.new(:url, :channel) do
end

Cocoapods = Struct.new(:url) do
end

Frameworks = Struct.new(:omid) do
  attr_accessor :ogury_core
  attr_accessor :ogury_ads
  attr_accessor :ogury_choice_manager
end

Framework = Struct.new(:internal_version, :beta_version, :release_version) do
end

Directories = Struct.new(:build, :output, :test_derived_data, :test_app) do
end
