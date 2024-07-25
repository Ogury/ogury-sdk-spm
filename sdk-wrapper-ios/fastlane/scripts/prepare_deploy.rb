private_lane :build_frameworks do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  configuration = options[:configuration]
  version = options[:version]

  configuration.sdks.defaults.each do |sdk|
    xcodebuild(
      archive: true,
      workspace: configuration.workspace.file_path,
      scheme: configuration.schemes.default,
      destination: get_generic_destination(sdk),
      archive_path: "#{configuration.directories.build}/archives/#{configuration.project.name}-#{sdk}",
      xcargs: "MARKETING_VERSION=#{version} BITCODE_GENERATION_MODE='bitcode' CLANG_ENABLE_CODE_COVERAGE='NO' SKIP_INSTALL=NO",
    )
  end
end

private_lane :combine_frameworks do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  # Combine all frameworks into a single one
  inputs = ""

  configuration.sdks.defaults.each do |sdk|
    inputs += "-framework '#{configuration.directories.build}/archives/#{configuration.project.name}-#{sdk}.xcarchive/Products/Library/Frameworks/#{configuration.project.public_name}.framework' "
  end

  output_file = "#{configuration.directories.output}/#{configuration.project.public_name}.xcframework"

  Dir.chdir("..") do
    FileUtils.remove_dir(output_file) if File.directory?(output_file)

    sh("set -o pipefail && xcodebuild -create-xcframework #{inputs} -output '#{output_file}' | xcpretty")
  end
end

private_lane :create_artefact do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  configuration = options[:configuration]
  version = options[:version]
  environment = options[:environment]

  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(configuration.project.public_name, framework_suffix, version)
  podspec_filename = get_podspec_filename(configuration.project.public_name, framework_suffix)

  Dir.chdir("..") do
    sh("tar -czvf #{configuration.directories.output}/#{archive_filename} -C #{configuration.directories.output} #{configuration.project.public_name}.xcframework #{podspec_filename}")
  end
end

### COCOAPODS

private_lane :update_podspec do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:framework_suffix]
    raise "No framework suffix specified!".red
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
  framework_suffix = options[:framework_suffix]
  environment = options[:environment]
  version = options[:version]
  source_url = options[:source_url]

  output_file = get_podspec_filename(configuration.project.public_name, framework_suffix)
  artifactory_repository_name = get_artifactory_repository_name(environment)
  archive_filename = get_archive_filename(configuration.project.public_name, framework_suffix, version)

  ogury_core_version = get_module_version(environment, configuration.frameworks.ogury_core.internal_version, configuration.frameworks.ogury_core.beta_version, configuration.frameworks.ogury_core.release_version)
  ogury_ads_version = get_module_version(environment, configuration.frameworks.ogury_ads.internal_version, configuration.frameworks.ogury_ads.beta_version, configuration.frameworks.ogury_ads.release_version)
  ogury_choice_manager_version = get_module_version(environment, configuration.frameworks.ogury_choice_manager.internal_version, configuration.frameworks.ogury_choice_manager.beta_version, configuration.frameworks.ogury_choice_manager.release_version)

  erb(
    template: "./fastlane/templates/OgurySdk.podspec.json.erb",
    destination: "#{configuration.directories.output}/#{output_file}",
    placeholders: {
      :version => version,
      :framework_suffix => framework_suffix,
      :artifactory_repository_name => artifactory_repository_name,
      :ogury_core_version => ogury_core_version,
      :ogury_ads_version => ogury_ads_version,
      :ogury_choice_manager_version => ogury_choice_manager_version,
      :source_url => source_url + "/#{archive_filename}",
    },
  )
end
