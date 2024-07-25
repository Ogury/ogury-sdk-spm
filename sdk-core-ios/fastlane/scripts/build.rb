private_lane :build_core_framework do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:sdk]
    raise "No SDK specified!".red
  end

  configuration = options[:configuration]
  sdk = options[:sdk]

  build_ios_app(
    project: configuration.project.coreFilePath,
    configuration: "Debug",
    scheme: configuration.schemes.core,
    sdk: sdk,
    clean: true,
    skip_archive: true,
    skip_package_ipa: true,
  )
end
