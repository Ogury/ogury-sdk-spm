private_lane :test_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]

  run_tests(
    workspace: configuration.workspace.file_path,
    configuration: "Debug",
    scheme: configuration.schemes.default,
    devices: configuration.test_devices,
    sdk: sdk,
    clean: true,
    derived_data_path: configuration.directories.test_derived_data,
    xcodebuild_formatter: 'xcpretty',
    output_types:"json-compilation-database",
    output_files:"../../compilation-database.json",
    slack_url: configuration.slack.url,
    slack_channel: configuration.slack.channel,
    xcargs: "MACH_O_TYPE=mh_dylib"
  )
end
