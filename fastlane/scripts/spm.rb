require "open-uri"
require "fileutils"
require "tmpdir"

desc "Updates the package.swift file, upload it to spm repo, create a release branch, a tag and a release version"
lane :handle_spm do |options|
  environment = options[:environment]
  UI.user_error!("Missing environment") unless environment
  configuration = options[:configuration]

  configure_git_remotes
  ogury_sdk_version = get_module_version(environment, configuration.frameworks.ogury_sdk.internal_version, configuration.frameworks.ogury_sdk.beta_version, configuration.frameworks.ogury_sdk.release_version)
  update_spm_package(configuration: configuration, environment: environment)
  repo_type = environment == 'release' ? "official" : "private"
  push_spm_package(repo_type: repo_type, version: ogury_sdk_version)
  #create_spm_release(repo_type: repo_type, version: ogury_sdk_version)
end

desc "Update Ogury Package.swift with latest binaries & checksums"
lane :update_spm_package do |options|

  environment = options[:environment]
  UI.user_error!("Missing environment") unless environment
  configuration = options[:configuration]
  UI.user_error!("Missing configuration") unless configuration

  internal_mode = !(environment == "release" || environment == "beta")
  UI.message("🔧 Mode: #{internal_mode ? "Internal" : "Release"}")

  base_url = ""
  case environment
      when "release"
          base_url = "https://binaries.ogury.co"
      when "beta"
          base_url = "https://binaries.ogury.co/beta"
      else
          base_url = "https://binaries.ogury.co/internal/prod"
  end

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
    package_path = File.expand_path("../../OgurySdk/OgurySdk-SPM/Package.swift", __dir__)
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
  Dir.chdir("../OgurySdk/OgurySdk-SPM/") do
    sh "swift build --configuration release"
  end
end

###############################################################
# push_spm_package
###############################################################
lane :push_spm_package do |options|
  git_token    = ENV["GIT_TOKEN"]
  git_username = ENV["GIT_USERNAME"] || "weareogury"
  UI.user_error!("Missing GIT_TOKEN in environment") if git_token.to_s.strip.empty?

  repo_type  = options[:repo_type] || "official" # "official" or "private"
  repo_name  = repo_type == "private" ? "internal-ogury-sdk-spm" : "ogury-sdk-spm"
  branch     = options[:branch] || (options[:version] ? "release/#{options[:version]}" : "release-#{Time.now.utc.strftime('%Y%m%d-%H%M%S')}")
  commit_message  = options[:commit_message] || "Update Package.swift for #{options[:version] || branch}"
  repo_path = options[:repo_path] || "../OgurySdk/OgurySdk-SPM"

  raise "Repo path not found: #{repo_path}" unless Dir.exist?(repo_path)

  Dir.chdir(repo_path) do
    sh("git fetch #{repo_type} master")
    sh("git checkout -B #{branch} #{repo_type}/master")

    # Configure user for CI
    sh("git config user.name 'Jenkins CI'")
    sh("git config user.email 'ci@jenkins.local'")

    # Commit changes if there are any
    sh("git add .")
    sh("git commit -m \"#{commit_message}\" || true")
    sh("git push #{repo_type} #{branch}")

    UI.success("✅ Branch #{branch} pushed to #{repo_name} (remote: #{repo_type})")

    # Optional: create PR
    pr_title = "Release #{options[:version] || branch}"
    pr_body  = "Automated PR for SDK release #{options[:version] || branch}."
    UI.message("📬 Creating Pull Request for #{branch} → master")
    sh <<~SH
      curl -s -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer #{git_token}" \
        https://api.github.com/repos/ogury/#{repo_name}/pulls \
        -d '{
          "title": "#{pr_title}",
          "head": "#{branch}",
          "base": "master",
          "body": "#{pr_body}"
        }'
    SH
  end
end

###############################################################
# create_spm_release
###############################################################
desc "Tag and create a GitHub release for ogury-sdk-spm"
lane :create_spm_release do |options|
  git_token = ENV["GIT_TOKEN"]
  UI.user_error!("Missing GIT_TOKEN in environment") if git_token.to_s.strip.empty?

  version       = options[:version]
  repo_type     = options[:repo_type] || "official"
  repo_name     = repo_type == "private" ? "internal-ogury-sdk-spm" : "ogury-sdk-spm"
  repo_path     = options[:repo_path] || "../OgurySdk/OgurySdk-SPM"
  release_notes = options[:release_notes] || "Automated release #{version} generated by sdk-ios CI"

  raise "Missing version parameter" unless version
  raise "Repo path not found: #{repo_path}" unless Dir.exist?(repo_path)

  Dir.chdir(repo_path) do
    UI.message("🏷️ Tagging version #{version} on #{repo_name} (remote: #{repo_type})")

    sh("git fetch #{repo_type} --tags")
    sh("git tag #{version}")
    sh("git push #{repo_type} #{version}")

    UI.success("✅ Tag #{version} pushed to #{repo_name}")

    UI.message("🚀 Creating GitHub release for #{version}")

    sh <<~SH
      curl -s -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer #{git_token}" \
        https://api.github.com/repos/ogury/#{repo_name}/releases \
        -d '{
          "tag_name": "#{version}",
          "name": "v#{version}",
          "body": "#{release_notes}",
          "draft": false,
          "prerelease": true
        }'
    SH
  end
end

desc "Ensure both 'official' and 'private' Git remotes exist for OgurySdk-SPM"
lane :configure_git_remotes do
  Dir.chdir("../OgurySdk/OgurySdk-SPM") do
    # Liste les remotes existants
    existing_remotes = sh("git remote").split("\n").map(&:strip)

    # Définis les URLs officielles
    official_url = "git@github.com:ogury/ogury-sdk-spm.git"
    private_url  = "git@github.com:ogury/sdk-internal-spm.git"

    # Si 'official' n’existe pas, on le crée
    unless existing_remotes.include?("official")
      UI.message("🔹 Adding remote 'official' → #{official_url}")
      sh("git remote add official #{official_url}")
    else
      UI.message("✅ Remote 'official' already exists")
    end

    # Si 'private' n’existe pas, on le crée
    unless existing_remotes.include?("private")
      UI.message("🔹 Adding remote 'private' → #{private_url}")
      sh("git remote add private #{private_url}")
    else
      UI.message("✅ Remote 'private' already exists")
    end

    # Vérifie les remotes finaux
    sh("git remote -v")
  end
end

lane :update_submodule_before_build do |options|
  repo_path = options[:repo_path] || "../OgurySdk/OgurySdk-SPM"
  remote    = options[:remote] || "private"
  branch    = options[:branch] || "master"

  Dir.chdir(repo_path) do
    sh("git fetch #{remote}")
    sh("git checkout #{branch}")
    sh("git pull #{remote} #{branch}")
  end
end
