class Configuration
  attr_reader :project, :schemes, :sdks, :test_devices, :allowed_environments, :artifactory, :amazon, :slack, :cocoapods, :directories

  def initialize
    @project = Project.new("OguryCore", "OguryCore.xcodeproj")
    @schemes = Schemes.new("OguryCore")
    @sdks = Sdks.new(["iphoneos", "iphonesimulator"], ["iphonesimulator"])
    @test_devices = ["iPhone 12"]
    @allowed_environments = ["devc", "staging", "prod", "beta", "release"]
    @artifactory = Artifactory.new("https://ogury.jfrog.io/artifactory")
    @amazon = Amazon.new("https://binaries.ogury.co", "core-ios")
    @slack = Slack.new("https://hooks.slack.com/services/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", "#sdk-ios-ci-update")
    @cocoapods = Cocoapods.new("git@github.com:Ogury/ogury-cocoapods-repository.git")
    @directories = Directories.new("./jenkins/build", "./jenkins/output", "./jenkins/test_derived_data")
  end
end

Project = Struct.new(:name, :file_path) do
end

Schemes = Struct.new(:default) do
end

Sdks = Struct.new(:defaults, :tests) do
end

Artifactory = Struct.new(:url) do
end

Amazon = Struct.new(:url, :project_key) do
end

Slack = Struct.new(:url, :channel) do
end

Cocoapods = Struct.new(:url) do
end

Directories = Struct.new(:build, :output, :test_derived_data) do
end
