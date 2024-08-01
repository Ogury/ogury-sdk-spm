
private_lane :build_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end
  if !options[:workspace]
    raise "No workspace specified!".red
  end
  if !options[:scheme]
    raise "No scheme specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  workspace = options[:workspace]
  scheme = options[:scheme]

  build_ios_app(
    workspace: workspace,
    configuration: "Debug",
    scheme: scheme,
    sdk: sdk,
    clean: true,
    skip_archive: true,
    skip_package_ipa: true,
  )
end

private_lane :build_core_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]

  puts "Compiling OguryCore".yellow

  build_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: configuration.targets.core.scheme
    )
end

private_lane :build_ads_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  artifactory = options[:artifactory] ? options[:artifactory] : false
  scheme = artifactory ? configuration.targets.ads.scheme : configuration.targets.ads.artScheme

  puts "Compiling OguryAds".blue

  build_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: scheme
    )
end

private_lane :build_card_library do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  artifactory = options[:artifactory] ? options[:artifactory] : false
  scheme = artifactory ? configuration.targets.adsLibrary.scheme : configuration.targets.adsLibrary.artScheme
  
  puts "Compiling AdsCardLibrary".yellow

  build_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: scheme
    )
end

private_lane :build_wrapper do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  
  puts "Compiling OgurySdk".green

  build_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: configuration.targets.wrapper.scheme
    )
end

### build test App
private_lane :build_test_app do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]
  
  puts "Building TestApp".green

  TestAppVariant.all.each do |variant|
    
    puts "Building #{configuration.targets.testApp.scheme}-#{variant}".blue
    artifactory = options[:artifactory] ? options[:artifactory] : false
    scheme = "#{configuration.targets.testApp.scheme}-#{variant}"
    scheme =  artifactory ? "#{scheme}-Release" : scheme

    build_ios_app(
      workspace: configuration.workspace.file_path,
      configuration: "Debug",
      scheme: scheme,
      sdk: "iphoneos",
      clean: true,
      output_directory: configuration.directories.test_app,
      output_name: "#{scheme}.ipa",
      export_method: "development",
      export_options: {
        signingStyle: "manual",
        provisioningProfiles: {
          "co.ogury.Test-Application" => "Test Application Dev",
        },
      },
      )

    copy_artifacts(
      target_path: "artifacts",
      artifacts: ["#{scheme}.ipa"]
      )

    firebase_app_distribution(
      app: "1:433541045380:ios:715a877bd12614bd0c36d1",
      testers: configuration.firebase.test_group,
      firebase_cli_token: "1//03VqloLsbSYJoCgYIARAAGAMSNwF-L9IrdbY5QQQDTEUBtWKAbeT0dxPkwNb0okDx1AIbr8Xli4R2-Ez6ZQMfVycZtf_Hv488wZg",
      release_notes: "",
      )
  end
end
