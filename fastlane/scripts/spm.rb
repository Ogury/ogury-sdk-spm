
require "open-uri"
require "fileutils"
require "tmpdir"
###############################################################
# update_spm_package
#
# Fully replaces update_package.rb logic inside Fastlane
###############################################################
desc "Update Ogury Package.swift with latest binaries & checksums"
lane :update_spm_package do |options|

  environment = options[:environment]
  UI.user_error!("Missing environment") unless environment
  configuration = options[:configuration]
  UI.user_error!("Missing configuration") unless configuration

  internal_mode = !(environment == "release" || environment == "beta")
  base_url = internal_mode ? "https://binaries.ogury.co/internal/prod" : "https://binaries.ogury.co"

  UI.message("🔧 Mode: #{internal_mode ? "Internal" : "Release"}")

  ogury_core_version = get_module_version(environment, configuration.frameworks.ogury_core.internal_version, configuration.frameworks.ogury_core.beta_version, configuration.frameworks.ogury_core.release_version)
  ogury_ads_version = get_module_version(environment, configuration.frameworks.ogury_ads.internal_version, configuration.frameworks.ogury_ads.beta_version, configuration.frameworks.ogury_ads.release_version)
  ogury_sdk_version = get_module_version(environment, configuration.frameworks.ogury_sdk.internal_version, configuration.frameworks.ogury_sdk.beta_version, configuration.frameworks.ogury_sdk.release_version)

  sdks = [
    {
      name: "OguryWrapper",
      version: ogury_sdk_version,
      internal_path: "OgurySdk/OgurySdk-Prod-#{ogury_sdk_version}.zip",
      release_path: "ios/#{ogury_sdk_version}/OgurySdk-#{ogury_sdk_version}.zip"
    },
    {
      name: "OguryAds",
      version: ogury_ads_version,
      internal_path: "OguryAds/OguryAds-Prod-#{ogury_ads_version}.zip",
      release_path: "ads-ios/#{ogury_ads_version}/OguryAds-#{ogury_ads_version}.zip"
    },
    {
      name: "OguryCore",
      version: ogury_core_version,
      internal_path: "OguryCore/OguryCore-Prod-#{ogury_core_version}.zip",
      release_path: "core-ios/#{ogury_core_version}/OguryCore-#{ogury_core_version}.zip"
    },
    {
      name: "OMSDK_Ogury",
      version: ogury_ads_version,
      internal_path: "OMSDK_Ogury/OMSDK_Ogury-Prod-#{ogury_ads_version}.zip",
      release_path: "ads-ios/#{ogury_ads_version}/OMSDK_Ogury-#{ogury_ads_version}.zip"
    }
  ]

  UI.message("🔽 Downloading SDKs and computing checksums...")

  Dir.mktmpdir("ogury_sdk") do |tmp_dir|
    sdks.each do |sdk|
      zip_path = internal_mode ? sdk[:internal_path] : sdk[:release_path]
      download_url = "#{base_url}/#{zip_path}"
      local_zip = File.join(tmp_dir, zip_path)

      FileUtils.mkdir_p(File.dirname(local_zip))

      UI.message("⬇️  Downloading #{sdk[:name]} from #{download_url}")
      URI.open(download_url) do |remote|
        File.write(local_zip, remote.read)
      end

      UI.message("🧮 Computing checksum for #{zip_path}")
      checksum = sh("swift package compute-checksum #{local_zip}", log: false).strip
      sdk[:url] = download_url
      sdk[:checksum] = checksum
    end

    UI.message("📝 Updating Package.swift...")
    package_path = File.expand_path("../Package.swift", __dir__)
    package_contents = File.read(package_path)

    sdks.each do |sdk|
      UI.message("🔁 Updating #{sdk[:name]} in Package.swift")

      url_pattern = /(name:\s*"#{Regexp.escape(sdk[:name])}".*?url:\s*")[^"]+(")/m
      checksum_pattern = /(name:\s*"#{Regexp.escape(sdk[:name])}".*?\n\s*checksum:\s*")[^"]*(")/m
      fallback_pattern = /(name:\s*"#{Regexp.escape(sdk[:name])}".*?\n.*?checksum:\s*")[^"]*(")/m

      package_contents.gsub!(url_pattern) { "#{$1}#{sdk[:url]}#{$2}" }

      if package_contents.match?(checksum_pattern)
        package_contents.gsub!(checksum_pattern) { "#{$1}#{sdk[:checksum]}#{$2}" }
      else
        package_contents.gsub!(fallback_pattern) { "#{$1}#{sdk[:checksum]}#{$2}" }
      end
    end

    File.write(package_path, package_contents)
    UI.success("✅ Package.swift updated.")
  end
end

###############################################################
# build_spm_package
###############################################################
desc "Build the Ogury SPM package for validation"
lane :build_spm_package do
  Dir.chdir("../ogury-sdk-spm") do
    sh "swift build --configuration release"
  end
end

###############################################################
# push_spm_package
###############################################################
desc "Push updated Package.swift to ogury-sdk-spm"
lane :push_spm_package do |options|
  branch = options[:branch] || "main"
  Dir.chdir("../ogury-sdk-spm") do
    sh "git config user.name 'Jenkins CI'"
    sh "git config user.email 'ci@jenkins.local'"
    sh "git add Package.swift"
    sh "git commit -m 'Update Package.swift from sdk-ios build' || true"
    sh "git push origin #{branch}"
  end
end

###############################################################
# create_spm_release
###############################################################
desc "Tag and create a GitHub release for ogury-sdk-spm"
lane :create_spm_release do |options|
  version = options[:version]
  release_notes = options[:release_notes] || "Automated release #{version} generated by sdk-ios CI"
  raise "Missing version parameter" unless version

  Dir.chdir("../ogury-sdk-spm") do
    sh "git tag #{version}"
    sh "git push origin #{version}"
  end

  github_api_token = ENV["GITHUB_TOKEN"]
  raise "GITHUB_TOKEN missing" unless github_api_token

  sh <<~SH
    curl -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer #{github_api_token}" \
      https://api.github.com/repos/ogury/ogury-sdk-spm/releases \
      -d '{
        "tag_name": "#{version}",
        "name": "v#{version}",
        "body": "#{release_notes}",
        "draft": false,
        "prerelease": false
      }'
  SH
end

###############################################################
# deploy_spm_package (main CI entry point)
###############################################################
desc "Update, build, push, and release the Ogury SPM package"
lane :deploy_spm_package do |options|
  version = options[:version]
  update_spm_package(internal: options[:internal])
  build_spm_package
  push_spm_package(branch: "main")
  create_spm_release(version: version, release_notes: options[:release_notes])
end