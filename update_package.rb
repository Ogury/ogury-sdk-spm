#!/usr/bin/env ruby

require "open-uri"
require "fileutils"
require "tmpdir"

require_relative "./configuration"

PACKAGE_SWIFT_PATH = "Package.swift"

# Build download URL map
sdks = [
  {
    name: "OguryWrapper",
    version: OGURY_WRAPPER_VERSION,
    zip_name: "OgurySdk"
  },
  {
    name: "OguryAds",
    version: OGURY_ADS_VERSION,
    zip_name: "OguryAds"
  },
  {
    name: "OguryCore",
    version: OGURY_CORE_VERSION,
    zip_name: "OguryCore"
  },
  {
    name: "OMSDK",
    version: OMSDK_VERSION,
    zip_name: "OMSDK"
  }
]

puts "🔽 Downloading SDKs and computing checksums..."

Dir.mktmpdir("ogury_sdk") do |tmp_dir|
  sdks.each do |sdk|
    zip_filename = "#{sdk[:zip_name]}-#{sdk[:version]}.zip"
    download_url = "https://ads-ios-sdk.ogury.co/spm/dynamic/#{zip_filename}"
    local_zip = File.join(tmp_dir, zip_filename)

    # Ensure parent directory exists (important for paths like "static/OMSDK_Ogury")
    FileUtils.mkdir_p(File.dirname(local_zip))
  
    puts "⬇️ Downloading #{sdk[:name]} from #{download_url}"
    URI.open(download_url) do |remote|
      File.write(local_zip, remote.read)
    end
  
    puts "🧮 Computing checksum for #{zip_filename}"
    checksum = `swift package compute-checksum #{local_zip}`.strip
    sdk[:url] = download_url
    sdk[:checksum] = checksum
  end

  puts "📝 Updating Package.swift..."

  package_swift_path = File.expand_path("Package.swift", __dir__)
  package_contents = File.read(package_swift_path)
  
  sdks.each do |sdk|
    puts "🔁 Updating #{sdk[:name]} in Package.swift"
  
    # Construct patterns
    url_pattern = %r{(name: "#{Regexp.escape(sdk[:name])}".*?url:\s*")[^"]+(")}m

    # Match and replace the checksum line for the correct target
    checksum_pattern = %r{(name:\s*"#{Regexp.escape(sdk[:name])}".*?\n\s*checksum:\s*")[^"]*(")}m
    
    if package_contents.match?(checksum_pattern)
      package_contents.gsub!(checksum_pattern) { "#{$1}#{sdk[:checksum]}#{$2}" }
    else
      # fallback: replace any line that looks like checksum: "..." and comes after the right name:
      fallback_checksum_pattern = %r{(name:\s*"#{Regexp.escape(sdk[:name])}".*?\n.*?checksum:\s*")[^"]*(")}m
      package_contents.gsub!(fallback_checksum_pattern) { "#{$1}#{sdk[:checksum]}#{$2}" }
    end

    # Replace URL
    package_contents.gsub!(url_pattern) do |match|
      "#{$1}#{sdk[:url]}#{$2}"
    end
  end
  
  # Write back only if changed
  File.write(package_swift_path, package_contents)
  puts "✅ Package.swift updated."
  end

# Optional: create GitHub release
if ARGV.include?("--tag")
  version = sdks["OguryWrapper"][:version]
  tag = "v#{version}"
  puts "🏷️  Creating GitHub release #{tag}..."
  system("git add Package.swift")
  system("git commit -m 'Update Ogury SDK to #{version}'")
  system("git tag #{tag}")
  system("git push origin #{tag}")
  puts "🚀 Release #{tag} pushed."
end

puts "✅ Done."