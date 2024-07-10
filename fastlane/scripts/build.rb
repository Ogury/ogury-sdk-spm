require 'sdk-ads-ios/fastlane/scripts/build'
require 'sdk-core-ios/fastlane/scripts/build'
require 'sdk-wrapper-ios/fastlane/scripts/build'

private_lane :build_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]

  build_ios_app(
    workspace: configuration.workspace.file_path,
    configuration: "Debug",
    scheme: configuration.schemes.default,
    sdk: sdk,
    clean: true,
    skip_archive: true,
    skip_package_ipa: true,
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

  build_ios_app(
    workspace: configuration.workspace.file_path,
    configuration: "Debug",
    scheme: configuration.schemes.adsLibrary,
    sdk: sdk,
    clean: true,
    skip_archive: true,
    skip_package_ipa: true,
  )
end

### build test App
private_lane :build_test_app do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  build_ios_app(
    workspace: configuration.workspace.file_path,
    configuration: "Debug",
    scheme: configuration.schemes.test_app,
    sdk: "iphoneos",
    clean: true,
    output_directory: configuration.directories.test_app,
    output_name: "ios_ads_test.ipa",
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
    artifacts: ["ios_ads_test.ipa"]
  )

  firebase_app_distribution(
    app: "1:433541045380:ios:715a877bd12614bd0c36d1",
    testers: configuration.firebase.test_group,
    firebase_cli_token: "1//03VqloLsbSYJoCgYIARAAGAMSNwF-L9IrdbY5QQQDTEUBtWKAbeT0dxPkwNb0okDx1AIbr8Xli4R2-Ez6ZQMfVycZtf_Hv488wZg",
    release_notes: "",
  )
end
