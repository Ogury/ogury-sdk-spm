class Configuration
  attr_reader :workspace, :targets, :schemes, :sdks, :test_devices, :allowed_environments, :firebase, :deployment, :slack, :cocoapods, :frameworks, :directories, :testApplications

  def initialize
    @workspace = Workspace.new("OgurySdks", "OgurySdks.xcworkspace")
    
    core = Target.new(name: "OguryCore", path: "sdk-core-ios/OguryCore.xcodeproj", scheme: "OguryCore", publicName: nil, dependencies: Dependency.new(hasPodspec: true), method: "core", amazon: "core-ios")
    ads = Target.new(name: "OguryAds", path: "sdk-ads-ios/OguryAdsSDK.xcodeproj", scheme: "OguryAds", publicName: nil, dependencies: Dependency.new(core: true, omid: true, hasPodspec: true), method: "ads", amazon: "ads-ios")
    wrapper = Target.new(name: "OguryWrapper", path: "sdk-wrapper-ios/OguryWrapper/OguryWrapper.xcodeproj", scheme: "OguryWrapper", publicName: "OgurySdk", dependencies: Dependency.new(core: true, ads: true, hasPodspec: true), method: "wrapper", amazon: "ios")
    omid = OmidTarget.new(name: "OMSDK_Ogury", path: "./sdk-ads-ios/", amazon: "omid-ios")
    @targets = Targets.new(ads, core, wrapper, omid)
    iosSdk = Sdk.new("iphoneos", "generic/platform=iOS")
    simulatorSdk = Sdk.new("iphonesimulator", "generic/platform=iOS Simulator")
    @sdks = Sdks.new([iosSdk, simulatorSdk], [simulatorSdk])
    @test_devices = ["iPhone 16"]
    @allowed_environments = ["devc", "staging", "prod", "beta", "release"]
    @firebase = Firebase.new("inApp")
    internalRepositories = Repositories.new(Repository.new("ogury-sdk-binaries/internal"), Repository.new("Ogury/sdk-internal-cocoapods"), Repository.new("https://github.com/Ogury/sdk-internal-spm"))
    publicRepositories = Repositories.new(Repository.new("ogury-sdk-binaries"), Repository.new("https://cdn.cocoapods.org/"), Repository.new("https://github.com/Ogury/ogury-sdk-spm"))
    @deployment = Deployment.new(internalRepositories, publicRepositories)
    @slack = Slack.new("https://hooks.slack.com/services/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", "#sdk-ios-ci-update")
    #@cocoapods = Cocoapods.new("git@github.com:Ogury/ogury-cocoapods-repository.git")
    @frameworks = Frameworks.new()
    @frameworks.ogury_core = Framework.new("2.1.0-NewTestApp-1.0.2", "2.0.0", "2.0.0")
    @frameworks.ogury_ads = Framework.new("4.1.0-NewTestApp-1.0.7", "4.0.0", "4.0.0")
    @frameworks.ogury_sdk = Framework.new("5.1.0-NewTestApp-1.0.8", "5.0.0", "5.0.0")
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

Targets = Struct.new(:ads, :core, :wrapper, :omid) do
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
  attr_accessor :name, :projectName, :path, :scheme, :publicName, :dependencies, :method, :amazon, :buildable

  def initialize(name:, projectName: nil, path:, scheme:, publicName: nil, dependencies: nil, method:, amazon:, buildable: true)
    @name = name
    @projectName = projectName.nil? ? name : projectName
    @path = path
    @scheme = scheme
    @buildable = buildable
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

class OmidTarget < Target
  def initialize(name:, path:, amazon:)
    super(name: name, projectName: "OguryAds", path: path, scheme: "", publicName: name, dependencies: Dependency.new(hasPodspec: true), method: "omid", amazon: amazon, buildable: false)
  end
end

Sdks = Struct.new(:defaults, :tests) do
end

Sdk = Struct.new(:platform, :destination) do
end

Firebase = Struct.new(:test_group) do
end

Deployment = Struct.new(:internal, :public) do
end
Repositories = Struct.new(:s3, :cocoapods, :spm) do
end
Repository = Struct.new(:url) do
end

Amazon = Struct.new(:url) do
end

Slack = Struct.new(:url, :channel) do
end

Cocoapods = Struct.new(:url) do
end

Frameworks = Struct.new() do
  attr_accessor :ogury_core
  attr_accessor :ogury_ads
  attr_accessor :ogury_sdk
end

Framework = Struct.new(:internal_version, :beta_version, :release_version) do
end

Directories = Struct.new(:build, :output, :test_derived_data, :test_app) do
end
