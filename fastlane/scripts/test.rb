
private_lane :test_framework do |options|
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

  run_tests(
    workspace: workspace,
    configuration: "Debug",
    scheme: scheme,
    devices: configuration.test_devices,
    sdk: sdk.platform,
    clean: true,
    derived_data_path: configuration.directories.test_derived_data,
    slack_url: configuration.slack.url,
    slack_channel: configuration.slack.channel,
    xcodebuild_formatter: 'xcpretty',
    xcargs: "ONLY_ACTIVE_ARCH=NO ENABLE_USER_SCRIPT_SANDBOXING=NO",
    build_for_testing: false
  )
end

private_lane :test_core_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]

  puts "Testing OguryCore".yellow

  test_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: configuration.targets.core.scheme
    )
end


private_lane :test_ads_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  scheme = configuration.targets.ads.scheme

  puts "Testing OguryAds".blue

  test_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: scheme
    )
end

private_lane :test_wrapper do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end
  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]
  
  puts "Testing OgurySdk".green

  test_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: configuration.targets.wrapper.scheme
    )
end
