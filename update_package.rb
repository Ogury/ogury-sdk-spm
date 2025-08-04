#!/usr/bin/env ruby

require "open-uri"
require "fileutils"
require "tmpdir"

require_relative "./configuration"

PACKAGE_SWIFT_PATH = "Package.swift"
INTERNAL_MODE = ARGV.include?("--internal")

puts "🔧 Mode: #{INTERNAL_MODE ? "Internal" : "Release"}"

BASE_URL = INTERNAL_MODE ? "https://binaries.ogury.co/internal/prod" : "https://binaries.ogury.co"

# Define SDKs and their specific paths
sdks = [
  {
    name: "OguryWrapper",
    version: OGURY_WRAPPER_VERSION,
    internal_path: "OgurySdk/OgurySdk-Prod-#{OGURY_WRAPPER_VERSION}.zip",
    release_path: "ios/#{OGURY_WRAPPER_VERSION}/OgurySdk-#{OGURY_WRAPPER_VERSION}.zip"
  },
  {
    name: "OguryAds",
    version: OGURY_ADS_VERSION,
    internal_path: "OguryAds/OguryAds-Prod-#{OGURY_ADS_VERSION}.zip",
    release_path: "ads-ios/#{OGURY_ADS_VERSION}/OguryAds-#{OGURY_ADS_VERSION}.zip"
  },
  {
    name: "OguryCore",
    version: OGURY_CORE_VERSION,
    internal_path: "OguryCore/OguryCore-Prod-#{OGURY_CORE_VERSION}.zip",
    release_path: "core-ios/#{OGURY_CORE_VERSION}/OguryCore-#{OGURY_CORE_VERSION}.zip"
  },
  {
    name: "OMSDK_Ogury",
    version: OMSDK_VERSION,
    internal_path: "OMSDK_Ogury/OMSDK_Ogury-Prod-#{OMSDK_VERSION}.zip",
    release_path: "ads-ios/#{OGURY_ADS_VERSION}/OMSDK_Ogury-#{OMSDK_VERSION}.zip"
  }
]

puts "🔽 Downloading SDKs and computing checksums..."

Dir.mktmpdir("ogury_sdk") do |tmp_dir|
  sdks.each do |sdk|
    zip_path = INTERNAL_MODE ? sdk[:internal_path] : sdk[:release_path]
    download_url = "#{BASE_URL}/#{zip_path}"
    local_zip = File.join(tmp_dir, zip_path)

    FileUtils.mkdir_p(File.dirname(local_zip))

    puts "⬇️ Downloading #{sdk[:name]} from #{download_url}"
    URI.open(download_url) do |remote|
      File.write(local_zip, remote.read)
    end

    puts "🧮 Computing checksum for #{zip_path}"
    checksum = `swift package compute-checksum #{local_zip}`.strip
    sdk[:url] = download_url
    sdk[:checksum] = checksum
  end

  puts "📝 Updating Package.swift..."

  package_swift_path = File.expand_path(PACKAGE_SWIFT_PATH, __dir__)
  package_contents = File.read(package_swift_path)

  sdks.each do |sdk|
    puts "🔁 Updating #{sdk[:name]} in Package.swift"

    url_pattern = %r{(name:\s*"#{Regexp.escape(sdk[:name])}".*?url:\s*")[^"]+(")}m
    checksum_pattern = %r{(name:\s*"#{Regexp.escape(sdk[:name])}".*?\n\s*checksum:\s*")[^"]*(")}m
    fallback_checksum_pattern = %r{(name:\s*"#{Regexp.escape(sdk[:name])}".*?\n.*?checksum:\s*")[^"]*(")}m

    # Replace URL
    package_contents.gsub!(url_pattern) { "#{$1}#{sdk[:url]}#{$2}" }

    # Replace checksum
    if package_contents.match?(checksum_pattern)
      package_contents.gsub!(checksum_pattern) { "#{$1}#{sdk[:checksum]}#{$2}" }
    else
      package_contents.gsub!(fallback_checksum_pattern) { "#{$1}#{sdk[:checksum]}#{$2}" }
    end
  end

  File.write(package_swift_path, package_contents)
  puts "✅ Package.swift updated."
end

# Optional: Git tag and push
if ARGV.include?("--tag")
  version = sdks.find { _1[:name] == "OguryWrapper" }[:version]
  tag = "v#{version}"
  puts "🏷️  Creating GitHub release with tag #{tag}..."
  system("git add Package.swift")
  system("git commit -m 'Update Ogury SDK to #{version}'")
  system("git tag #{tag}")
  system("git push origin #{tag}")
  puts "🚀 Release #{tag} pushed."
end

puts "✅ Done."