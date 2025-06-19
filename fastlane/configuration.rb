class Configuration
  attr_reader :workspace, :targets, :schemes, :sdks, :test_devices, :allowed_environments, :firebase, :artifactory, :amazon, :slack, :cocoapods, :frameworks, :directories, :testApplications

  def initialize
    @workspace = Workspace.new("OgurySdks", "OgurySdks.xcworkspace")
    core = Target.new("OguryCore", "sdk-core-ios/OguryCore.xcodeproj", "OguryCore", nil, Dependency.new(hasPodspec: true), "core", "core-ios")
    ads = Target.new("OguryAds", "sdk-ads-ios/OguryAdsSDK.xcodeproj", "OguryAds", nil, Dependency.new(core: true, omid: true, hasPodspec: true), "ads", "ads-ios")
    wrapper = Target.new("OguryWrapper", "sdk-wrapper-ios/OguryWrapper/OguryWrapper.xcodeproj", "OguryWrapper", "OgurySdk", Dependency.new(core: true, ads: true, hasPodspec: true), "wrapper", "ios")
    @targets = Targets.new(ads, core, wrapper)
    iosSdk = Sdk.new("iphoneos", "generic/platform=iOS")
    simulatorSdk = Sdk.new("iphonesimulator", "generic/platform=iOS Simulator")
    @sdks = Sdks.new([iosSdk, simulatorSdk], [simulatorSdk])
    @test_devices = ["iPhone 16"]
    @allowed_environments = ["devc", "staging", "prod", "beta", "release"]
    @firebase = Firebase.new("inApp")
    @artifactory = Artifactory.new("https://ogury.jfrog.io/artifactory")
    @amazon = Amazon.new("https://binaries.ogury.co")
    @slack = Slack.new("https://hooks.slack.com/services/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", "#sdk-ios-ci-update")
    @cocoapods = Cocoapods.new("git@github.com:Ogury/ogury-cocoapods-repository.git")
    @frameworks = Frameworks.new("./OMSDK_Ogury.xcframework")
    @frameworks.ogury_core = Framework.new("2.0.0-rc-1.0.0", "2.0.0", "2.0.0")
    @frameworks.ogury_ads = Framework.new("4.0.2-rc-1.0.0", "4.0.0", "4.0.0")
    @frameworks.ogury_sdk = Framework.new("5.0.1-rc-1.0.1", "5.0.0", "5.0.0")
    @directories = Directories.new("./jenkins/build", "./jenkins/output", "./jenkins/test_derived_data", "./jenkins/testApp")
    prodTestApp = TestApplication.new("prodTestApp", "AdsTestApp-Prod", nil, "co.ogury.sdk.ads.app", "1:743372999564:ios:b2fa9c2a0751d1abca24a9")
    devcTestApp = TestApplication.new("devcTestApp", "AdsTestApp-Devc", nil, "co.ogury.sdk.ads.app.devc", "1:743372999564:ios:a479c7c9a882a87bca24a9")
    stagingTestApp = TestApplication.new("stagingTestApp", "AdsTestApp-Staging", nil, "co.ogury.sdk.ads.app.staging", "1:743372999564:ios:8f14df7190bfc06cca24a9")
    maxTestApp = TestApplication.new("maxTestApp", "MaxTestApp", "MaxTestApp", "co.ogury.sdk.ads.max.app", "1:743372999564:ios:cc7358fc83c446edca24a9")
    adMobTestApp = TestApplication.new("adMobTestApp", "AdMobTestApp", "AdMobTestApp", "co.ogury.sdk.ads.admob.app", "1:743372999564:ios:126315fea3608a04ca24a9")
    unityTestApp = TestApplication.new("unityTestApp", "UnityLevelPlayTestApp", "UnityLevelPlayTestApp", "co.ogury.sdk.ads.ulp.app", "1:743372999564:ios:4c84c9f1f5248edaca24a9")
    prebidTestApp = TestApplication.new("prebidTestApp", "PrebidTestApp", "PrebidTestApp", "co.ogury.sdk.ads.prebid.devc", "1:743372999564:ios:c00cac288d327678ca24a9
")
    @testApplications = TestApplications.new([prodTestApp, devcTestApp, stagingTestApp], [maxTestApp, adMobTestApp, unityTestApp, prebidTestApp])
  end
end

Workspace = Struct.new(:name, :file_path) do
end

class TestApplication 
  attr_accessor :name, :scheme, :artScheme, :bundleId, :firebaseAppId

  def initialize(name, scheme, artScheme = nil, bundleId, firebaseAppId)
    @name = name
    @scheme = scheme
    @artScheme = artScheme.nil? ? "#{scheme}-art" : artScheme
    @bundleId = bundleId
    @firebaseAppId = firebaseAppId
  end
end

class TestApplications
  def initialize(ogury_apps, mediation_apps)
    @ogury = ogury_apps.compact
    @mediation = mediation_apps.compact
  end

  def all
    @ogury + @mediation
  end

  def ogury
    @ogury
  end

  def mediation
    @mediation
  end

  def find_by_name(name)
    all.find { |app| app.name == name }
  end
end

Targets = Struct.new(:ads, :core, :wrapper) do
end

class Dependency
  attr_accessor :core, :ads, :omid, :adsLibrary, :wrapper, :hasPodspec

  def initialize(core: false, ads: false, omid: false, wrapper: false, hasPodspec: false)
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

  def initialize(name, path, scheme, publicName = nil, dependencies = nil, method, amazon)
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
  attr_accessor :ogury_sdk
end

Framework = Struct.new(:internal_version, :beta_version, :release_version) do
end

Directories = Struct.new(:build, :output, :test_derived_data, :test_app) do
end
