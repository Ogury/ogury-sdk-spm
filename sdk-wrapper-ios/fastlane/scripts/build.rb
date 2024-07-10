private_lane :build_wrapper_framework do |options|
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
    scheme: configuration.schemes.wrapper,
    sdk: sdk,
    clean: true,
    skip_archive: true,
    skip_package_ipa: true
  )
end

private_lane :build_wrapper_test_app do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  build_ios_app(
    workspace: configuration.workspace.wrapperFilePath,
    configuration: "Debug",
    scheme: configuration.schemes.test_app,
    sdk: "iphoneos",
    clean: true,
    output_directory: configuration.directories.test_app,
    output_name: "ios_wrapper_test_app.ipa",
    export_method: "development",
    export_options: {
      signingStyle: "manual",
      provisioningProfiles: {
        "com.ogury.wrapper.testApp" => "wrapper test Application",
      },
    },
  )
=begin
  firebase_app_distribution(
    app: "1:433541045380:ios:1f9c892421663cfd0c36d1",
    testers: configuration.firebase.test_group,
    firebase_cli_token: "1//03VqloLsbSYJoCgYIARAAGAMSNwF-L9IrdbY5QQQDTEUBtWKAbeT0dxPkwNb0okDx1AIbr8Xli4R2-Ez6ZQMfVycZtf_Hv488wZg",
    release_notes: "",
  )
=end

end
