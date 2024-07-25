require "json"

desc "Archive the framework for the specified scheme and destination"
private_lane :build_frameworks do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:environment_url]
    raise "No environment_url specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  version = options[:version]
  destination = ""

  configuration.sdks.defaults.each do |sdk|
    case sdk
    when "iphonesimulator"
      destination = "generic/platform=iOS Simulator"
    when "iphoneos"
      destination = "generic/platform=iOS"
    end

    puts "Compiling OguryAds".green
    xcodebuild(
      archive: true,
      workspace: configuration.workspace.file_path,
      scheme: configuration.schemes.default,
      sdk: sdk,
      clean: true,
      destination: destination,
      xcargs: "CLANG_ENABLE_CODE_COVERAGE=NO SKIP_INSTALL=NO MARKETING_VERSION=#{version} ENV_URL=#{options[:environment_url]}",
      archive_path: "#{configuration.directories.build}/archives/#{configuration.project.name}-#{sdk}",
    )
  end
end

desc "Archive the card framework for the specified scheme and destination"
private_lane :build_card_frameworks do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:environment_url]
    raise "No environment_url specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  version = options[:version]
  destination = ""

  configuration.sdks.defaults.each do |sdk|
    case sdk
    when "iphonesimulator"
      destination = "generic/platform=iOS Simulator"
    when "iphoneos"
      destination = "generic/platform=iOS"
    end

    puts "Compiling AdsCardLibrary".green
    xcodebuild(
      archive: true,
      workspace: configuration.workspace.file_path,
      scheme: configuration.schemes.adsLibrary,
      sdk: sdk,
      clean: true,
      destination: destination,
      xcargs: "CLANG_ENABLE_CODE_COVERAGE=NO SKIP_INSTALL=NO MARKETING_VERSION=#{version} ENV_URL=#{options[:environment_url]}",
      archive_path: "#{configuration.directories.build}/archives/#{configuration.project.adsLibraryName}-#{sdk}",
    )
  end
end

private_lane :combine_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  puts "Creating OguryAds XCFramework"
  inputs = ""
  configuration.sdks.defaults.each do |sdk|
    inputs += "-framework '#{configuration.directories.build}/archives/#{configuration.project.name}-#{sdk}.xcarchive/Products/Library/Frameworks/#{configuration.project.name}.framework' "
  end

  output_file = "#{configuration.directories.output}/#{configuration.project.name}.xcframework"
  Dir.chdir("..") do
    FileUtils.remove_dir(output_file) if File.directory?(output_file)

    sh("set -o pipefail && xcodebuild -create-xcframework #{inputs} -output '#{output_file}' | xcpretty")
  end

  puts "Creating AdsCardLibrary XCFramework"
  inputs = ""
  configuration.sdks.defaults.each do |sdk|
    inputs += "-framework '#{configuration.directories.build}/archives/#{configuration.project.adsLibraryName}-#{sdk}.xcarchive/Products/Library/Frameworks/#{configuration.project.adsLibraryName}.framework' "
  end


  output_file = "#{configuration.directories.output}/#{configuration.project.adsLibraryName}.xcframework"
  Dir.chdir("..") do
    FileUtils.remove_dir(output_file) if File.directory?(output_file)

    sh("set -o pipefail && xcodebuild -create-xcframework #{inputs} -output '#{output_file}' | xcpretty")
  end
end

private_lane :copy_omsdk do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  Dir.chdir("..") do
    sh("cp -R #{configuration.frameworks.omid} #{configuration.directories.output}")
  end
end

private_lane :zip_famework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:version]
    raise "No tag specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  configuration = options[:configuration]
  version = options[:version]
  environment = options[:environment]

  puts "Zipping OguryAds"
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(configuration.project.name, framework_suffix, version)
  podspec_filename = get_podspec_filename(configuration.project.name, framework_suffix)
  omsdk_filename = File.basename(configuration.frameworks.omid)

  Dir.chdir("..") do
    sh("tar -czvf #{configuration.directories.output}/#{archive_filename} -C #{configuration.directories.output} #{configuration.project.name}.xcframework #{configuration.project.adsLibraryName}.xcframework #{podspec_filename} #{omsdk_filename}")
  end
end

private_lane :generate_podspec do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:source_url]
    raise "No source url specified!".red
  end

  configuration = options[:configuration]
  environment = options[:environment]
  version = options[:version]
  source_url = options[:source_url]
  
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(configuration.project.name, framework_suffix, version)
  output_file = get_podspec_filename(configuration.project.name, framework_suffix)

  content = JSON.parse(IO.read("./templates/OguryAds.podspec.json"))

  ogury_core_version = get_module_version(environment, configuration.frameworks.ogury_core.internal_version, configuration.frameworks.ogury_core.beta_version, configuration.frameworks.ogury_core.release_version)

  content["name"] = configuration.project.name + framework_suffix
  content["version"] = version
  content["vendored_frameworks"] = "#{configuration.project.name}.xcframework"
  content["dependencies"] = { "OguryCore#{framework_suffix}": ["#{ogury_core_version}"]}
  content["source"]["http"] = source_url + "/#{archive_filename}"
  content["subspecs"] = [{ "name": "OMID", "vendored_frameworks": "#{File.basename(configuration.frameworks.omid)}" }]

  # create the podspec
  Dir.chdir("..") do
    File.open("#{configuration.directories.output}/#{output_file}", "w") do |file|
      file.write(JSON.pretty_generate(content))
    end
  end
end

lane :prepare_for_deployment do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:tag]
    raise "No tag specified!".red
  end

  configuration = options[:configuration]
  environment = options[:environment]
  version = options[:version]
  tag = options[:tag]
  framework_suffix = get_framework_suffix(environment)

  # Source URL for Cocoapods
  source_url = ""
  case environment
  when "devc", "staging", "prod"
    # Artifactory
    source_url = "#{configuration.artifactory.url}/sdk-cocoapods-#{environment}/#{configuration.project.name}#{framework_suffix}"
  when "beta", "release"
    # S3 release / beta buckets
    source_url = "#{configuration.amazon.url}/#{environment}/#{configuration.amazon.project_key}/#{version}"
  end

  # Environment url for SDK
  environment_url = ""
  case environment
  when "devc"
    environment_url = "OGADevCURL"
  when "staging"
    environment_url = "OGAStagingURL"
  when "prod", "beta", "release"
    environment_url = "OGAProductionURL"
  end

  build_frameworks configuration: configuration, version: version, environment_url: environment_url
  build_card_frameworks configuration: configuration, version: version, environment_url: environment_url

  combine_framework configuration: configuration

  copy_omsdk configuration: configuration

  generate_podspec configuration: configuration, version: version, environment: environment, source_url: source_url

  zip_famework configuration: configuration, version: version, environment: environment
end
