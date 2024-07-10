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
    project: configuration.project.file_path,
    configuration: "Debug",
    scheme: configuration.schemes.default,
    devices: configuration.test_devices,
    sdk: sdk,
    clean: true,
    derived_data_path: configuration.directories.test_derived_data,
  )
end
