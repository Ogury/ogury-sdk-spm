class Configuration
  attr_reader :workspace, :targets, :schemes, :sdks, :test_devices, :allowed_environments, :firebase, :artifactory, :amazon, :slack, :cocoapods, :frameworks, :directories

  def initialize
    @workspace = Workspace.new("OgurySdks", "OgurySdks.xcworkspace")
    core = Target.new("OguryCore", "sdk-core-ios/OguryCore.xcodeproj", "OguryCore", "OguryCore", nil, Dependency.new(hasPodspec: true), "core", "core-ios")
    ads = Target.new("OguryAds", "sdk-ads-ios/OguryAdsSDK.xcodeproj", "OguryAds", nil, nil, Dependency.new(core: true, omid: true, hasPodspec: true), "ads", "ads-ios")
    adsLibrary = Target.new("AdsCardLibrary", "sdk-ads-ios/AdsCardLibrary/AdsCardLibrary.xcodeproj", "AdsCardLibrary", nil, nil, Dependency.new(core: true, ads: true), "adsLibrary", "adsLibrary-ios")
    wrapper = Target.new("OguryWrapper", "sdk-wrapper-ios/OguryWrapper/OguryWrapper.xcodeproj", "OguryWrapper", nil, "OgurySdk", Dependency.new(core: true, ads: true, hasPodspec: true), "wrapper", "ios")
    testApp = Target.new("AdsTestApp", "sdk-ads-ios/AdsTestApp/AdsTestApp.xcodeproj", "AdsTestApp", nil, nil, Dependency.new(core: true, ads: true), "testApp", "testApp-ios")
    @targets = Targets.new(ads, adsLibrary, core, wrapper, testApp)
    iosSdk = Sdk.new("iphoneos", "generic/platform=iOS")
    simulatorSdk = Sdk.new("iphonesimulator", "generic/platform=iOS Simulator")
    @sdks = Sdks.new([iosSdk, simulatorSdk], [simulatorSdk])
    @test_devices = ["iPhone 16"]
    @allowed_environments = ["devc", "staging", "prod", "beta", "release"]
    @firebase = Firebase.new("sdk-tester-group")
    @artifactory = Artifactory.new("https://ogury.jfrog.io/artifactory")
    @amazon = Amazon.new("https://binaries.ogury.co")
    @slack = Slack.new("https://hooks.slack.com/services/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", "#sdk-ios-ci-update")
    @cocoapods = Cocoapods.new("git@github.com:Ogury/ogury-cocoapods-repository.git")
    @frameworks = Frameworks.new("./OMSDK_Ogury.xcframework")
    @frameworks.ogury_core = Framework.new("2.0.0-rc-1.0.0", "2.0.0", "2.0.0")
    @frameworks.ogury_ads = Framework.new("4.0.1-rc-1.0.1", "4.0.0", "4.0.0")
    @frameworks.ogury_choice_manager = Framework.new("4.3.0-rc-2", "4.1.0-beta-1.0.0", "4.3.0")
    @directories = Directories.new("./jenkins/build", "./jenkins/output", "./jenkins/test_derived_data", "./jenkins/testApp")
  end
end

Workspace = Struct.new(:name, :file_path) do
end

Targets = Struct.new(:ads, :adsLibrary, :core, :wrapper, :testApp) do
end

class Dependency
  attr_accessor :core, :ads, :omid, :adsLibrary, :wrapper, :hasPodspec

  def initialize(core: false, ads: false, omid: false, adsLibrary: false, wrapper: false, hasPodspec: false)
    @core = core
    @ads = ads
    @omid = omid
    @adsLibrary = adsLibrary
    @wrapper = wrapper
    @hasPodspec = hasPodspec
  end
end

class Target
  attr_accessor :name, :path, :scheme, :artScheme, :publicName, :dependencies, :method, :amazon

  def initialize(name, path, scheme, artScheme = nil, publicName = nil, dependencies = nil, method, amazon)
    @name = name
    @path = path
    @scheme = scheme
    @artScheme = artScheme.nil? ? "#{scheme}-art" : artScheme
    @publicName = publicName.nil? ? name : publicName
    @method = method
    @amazon = amazon
    @dependencies = if dependencies.is_a?(Dependency)
                      dependencies
                    else
                      Dependency.new(**(dependencies || {}))
                    end
  end
end

module TestAppVariant
  DEVC = "Devc"
  STAGING = "Staging"
  PROD = "Prod"

  def self.all
    constants.map { |const| const_get(const) }
  end
end

Sdks = Struct.new(:defaults, :tests) do
end

Sdk = Struct.new(:platform, :destination) do
end

Firebase = Struct.new(:test_group) do
end

Artifactory = Struct.new(:url) do
end

Amazon = Struct.new(:url) do
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
