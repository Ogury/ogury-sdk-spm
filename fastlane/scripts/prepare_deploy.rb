require "json"

lane :prepare_for_deployment do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:target]
    raise "No target specified!".red
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
  target = options[:target]
  artifactory = options[:artifactory] ? options[:artifactory] : false

  # Source URL for Cocoapods
  source_url = ""
  case environment
  when "devc", "staging", "prod"
    # internal cocoapod
    source_url = "#{configuration.deployment.internal.s3.url}/#{environment}/#{target.publicName}"
  when "beta", "release"
    # S3 release / beta buckets
    source_url = "#{configuration.deployment.public.s3.url}/#{environment}/#{target.amazon}/#{version}"
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

  if target.buildable 
    build_frameworks(
      configuration: configuration, 
      version: version, 
      environment_url: environment_url, 
      target:target,
      artifactory: artifactory
      )
  
    combine_framework(
      configuration: configuration, 
      target: target
      )
  end

  if target.dependencies.hasPodspec
    generate_podspec(
      configuration: configuration,
      version: version, 
      environment: environment, 
      source_url: source_url,
      target: target
      )
  end

  zip_famework(
    configuration: configuration,
    version: version, 
    environment: environment,
    target: target
    )
end

desc "Archive the framework for the specified scheme and destination"
private_lane :build_frameworks do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  # if !options[:workspace]
  #   raise "No workspace specified!".red
  # end
  if !options[:target]
    raise "No target specified!".red
  end
  if !options[:version]
    raise "No version specified!".red
  end
  if !options[:environment_url]
    raise "No environment_url specified!".red
  end

  version = options[:version]
  destination = ""
  configuration = options[:configuration]
  target = options[:target]
  artifactory = options[:artifactory] ? options[:artifactory] : false
  scheme = artifactory ? target.artScheme : target.scheme

  configuration.sdks.defaults.each do |sdk|
    puts "Compiling #{target.scheme} to".green
    xcodebuild(
      archive: true,
      workspace: configuration.workspace.file_path,
      scheme: scheme,
      sdk: sdk.platform,
      destination: sdk.destination,
      clean: true,
      xcargs: "CLANG_ENABLE_CODE_COVERAGE=NO SKIP_INSTALL=NO MARKETING_VERSION=#{version} ENV_URL=#{options[:environment_url]}",
      archive_path: "#{configuration.directories.build}/archives/#{target.publicName}-#{sdk.platform}",
      )
  end
end

private_lane :combine_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:target]
    raise "No target specified!".red
  end

  configuration = options[:configuration]
  target = options[:target]

  puts "Creating #{target.name} XCFramework"
  inputs = ""
  configuration.sdks.defaults.each do |sdk|
    inputs += "-framework '#{configuration.directories.build}/archives/#{target.publicName}-#{sdk.platform}.xcarchive/Products/Library/Frameworks/#{target.publicName}.framework' "
  end

  output_file = "#{configuration.directories.output}/#{target.publicName}.xcframework"
  Dir.chdir("..") do
    FileUtils.remove_dir(output_file) if File.directory?(output_file)

    sh("set -o pipefail && xcodebuild -create-xcframework #{inputs} -output '#{output_file}' | xcpretty")
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
  if !options[:target]
    raise "No target specified!".red
  end

  configuration = options[:configuration]
  version = options[:version]
  environment = options[:environment]
  target = options[:target]

  puts "Zipping #{target}"
  files = ""
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(target.publicName, framework_suffix, version)
  files += "#{target.publicName}.xcframework "

#  if target.dependencies.hasPodspec
#    podspec_filename = get_podspec_filename(target.publicName, framework_suffix)
#    files += "#{podspec_filename} "
#  end

  puts "Files #{files}".red

  Dir.chdir("..") do
    sh("cd #{configuration.directories.output} && zip -r #{archive_filename} #{files}")
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

  if !options[:target]
    raise "No target specified!".red
  end

  configuration = options[:configuration]
  environment = options[:environment]
  version = options[:version]
  source_url = options[:source_url]
  target = options[:target]
  
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(target.publicName, framework_suffix, version)
  output_file = get_podspec_filename(target.publicName, framework_suffix)

  placeholders = {
    :version => version,
    :framework_suffix => framework_suffix,
    :source_url => source_url + "/#{archive_filename}"
  }

  if target.dependencies.core
    ogury_core_version = get_module_version(environment, configuration.frameworks.ogury_core.internal_version, configuration.frameworks.ogury_core.beta_version, configuration.frameworks.ogury_core.release_version)
    placeholders["ogury_core_version"] = ogury_core_version
  end

  if target.dependencies.ads
    ogury_ads_version = get_module_version(environment, configuration.frameworks.ogury_ads.internal_version, configuration.frameworks.ogury_ads.beta_version, configuration.frameworks.ogury_ads.release_version)
    placeholders["ogury_ads_version"] = ogury_ads_version
  end

  if target.dependencies.omid
    ogury_omid_version = get_module_version(environment, configuration.frameworks.ogury_ads.internal_version, configuration.frameworks.ogury_ads.beta_version, configuration.frameworks.ogury_ads.release_version)
    placeholders["ogury_omid_version"] = ogury_omid_version
  end

  erb(
    template: "#{Dir.pwd}/templates/#{target.publicName}.podspec.json.erb",
    destination: "#{configuration.directories.output}/#{output_file}",
    placeholders: placeholders,
    )
end



lane :prepare_core_for_deployment do |options|
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
  artifactory = options[:artifactory] ? options[:artifactory] : false

  puts "Deploy OguryCore".yellow

  prepare_for_deployment(
    configuration: configuration,
    environment: environment,
    version: version,
    tag: tag,
    target: configuration.targets.core,
    artifactory: artifactory
    )
end

lane :prepare_ads_for_deployment do |options|
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
  artifactory = options[:artifactory] ? options[:artifactory] : false

  puts "Deploy OguryAds".yellow

  prepare_for_deployment(
    configuration: configuration,
    environment: environment,
    version: version,
    tag: tag,
    target: configuration.targets.ads,
    artifactory: artifactory
    )
end

lane :prepare_omid_for_deployment do |options|
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
  artifactory = options[:artifactory] ? options[:artifactory] : false

  puts "Deploy OMSDK".yellow
  target = configuration.targets.omid

  #copy framework before deploying
  Dir.chdir("..") do
    sh("mkdir -p #{configuration.directories.output}")
    sh("cp -R #{target.path}#{target.name}.xcframework #{configuration.directories.output}")
  end

  prepare_for_deployment(
    configuration: configuration,
    environment: environment,
    version: version,
    tag: tag,
    target: target,
    artifactory: artifactory
    )
end

lane :prepare_wrapper_for_deployment do |options|
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
  artifactory = options[:artifactory] ? options[:artifactory] : false

  puts "Deploy OgurySdk".yellow

  prepare_for_deployment(
    configuration: configuration,
    environment: environment,
    version: version,
    tag: tag,
    target: configuration.targets.wrapper,
    artifactory: artifactory
    )
end

### build test App
private_lane :deploy_test_app do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]
  artifactory = options[:artifactory] ? options[:artifactory] : false
  isQa = options[:isQa] ? options[:isQa] : false
  killModeEnabled = options[:killModeEnabled] ? options[:killModeEnabled] : false
  
  ## the appSelector refers to Configuration.rb TestApplications variants
  selector = options[:appSelector]
  UI.user_error!("Missing app selector") unless selector

  setup_xcode
    
  update_internal_cocoapods environment: 'prod'
  generate_podfile(environment:'prod', targetThreshold:"all")
  cocoapods(
    podfile: "./Podfile",
    repo_update: true
  )
  
  puts "Building TestApp".green

  # Determine selection
  selected_apps = case selector
                  when "all"
                    configuration.testApplications.all
                  when "ogury"
                    configuration.testApplications.ogury
                  when "mediation"
                    configuration.testApplications.mediation
                  else
                    app = configuration.testApplications.all.find { |a| a.name == selector }
                    UI.user_error!("App '#{selector}' not found") unless app
                    [app]
                  end

  puts "Select apps -> #{selected_apps}".red

  selected_apps.each do |app|
    scheme =  artifactory ? app.artScheme : app.scheme
    bundleId = app.bundleId
    xcargs = []
    xcargs << (isQa ? "OTHER_SWIFT_FLAGS='$(OTHER_SWIFT_FLAGS) -DQA_MODE'" : "OTHER_SWIFT_FLAGS='$(OTHER_SWIFT_FLAGS)'")
    xcargs << (killModeEnabled ? "GCC_PREPROCESSOR_DEFINITIONS='$(inherited) KILL_MODE_ENABLED=1'" : "GCC_PREPROCESSOR_DEFINITIONS='$(inherited)'")
    xcargs = xcargs.join(' ')
    output_dir = File.join(configuration.directories.test_app, app.name)
    puts "Building #{scheme}".blue
    puts "bundleId #{bundleId}".yellow
    puts "output_dir #{output_dir}".red

    build_ios_app(
      workspace: configuration.workspace.file_path,
      scheme: scheme,
      sdk: "iphoneos",
      derived_data_path: output_dir,
      clean: true,
      xcargs: xcargs,
      output_directory: configuration.directories.test_app,
      output_name: "#{scheme}.ipa",
      export_method: "development",
      export_options: {
        signingStyle: "automatic"
        #provisioningProfiles: {
        #  bundleId => "XC co ogury sdk ads app #{variant.downcase}"
        #},
      },
    )

    copy_artifacts(
      target_path: "artifacts",
      artifacts: ["#{scheme}.ipa"]
      )

    firebase_app_distribution(
      app: app.firebaseAppId,
      testers: configuration.firebase.test_group,
      firebase_cli_token: "1//03VqloLsbSYJoCgYIARAAGAMSNwF-L9IrdbY5QQQDTEUBtWKAbeT0dxPkwNb0okDx1AIbr8Xli4R2-Ez6ZQMfVycZtf_Hv488wZg",
      release_notes: "",
      )
  end
end
