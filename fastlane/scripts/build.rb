
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
  killModeEnabled = options[:killModeEnabled] ? options[:killModeEnabled] : false
  xcargs = killModeEnabled ? "GCC_PREPROCESSOR_DEFINITIONS='$(inherited) KILL_MODE_ENABLED=1'" : "GCC_PREPROCESSOR_DEFINITIONS='$(inherited)'"

  build_ios_app(
    workspace: workspace,
    configuration: "Debug",
    scheme: scheme,
    sdk: sdk.platform,
    #xcargs:xcargs,
    destination: sdk.destination,
    clean: true,
    skip_archive: true,
    skip_package_ipa: true
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
  killModeEnabled = options[:killModeEnabled] ? options[:killModeEnabled] : false
  scheme = artifactory ? configuration.targets.ads.artScheme : configuration.targets.ads.scheme

  puts "Compiling OguryAds".blue

  build_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: scheme,
    killModeEnabled: killModeEnabled
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
  artifactory = options[:artifactory] ? options[:artifactory] : false
  scheme = artifactory ? configuration.targets.wrapper.artScheme : configuration.targets.wrapper.scheme
  
  puts "Compiling OgurySdk".green

  build_framework(
    configuration: configuration,
    sdk: sdk,
    workspace: configuration.workspace.file_path,
    scheme: scheme
    )
end
