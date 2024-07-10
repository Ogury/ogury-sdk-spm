require "json"

import("./scripts/utility_functions.rb")

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
      project: configuration.project.file_path,
      scheme: configuration.schemes.default,
      configuration: "Release",
      destination: get_generic_destination(sdk),
      archive_path: "#{configuration.directories.build}/#{configuration.project.name}-#{sdk}",
      xcargs: "MARKETING_VERSION=#{version} BITCODE_GENERATION_MODE='bitcode' CLANG_ENABLE_CODE_COVERAGE='NO' SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES",
    )
  end
end

private_lane :combine_frameworks do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  Dir.chdir("..") do
    sh("mkdir -p #{configuration.directories.output}")
  end

  # Combine all frameworks into a single one
  inputs = ""

  configuration.sdks.defaults.each do |sdk|
    inputs += "-framework '#{configuration.directories.build}/#{configuration.project.name}-#{sdk}.xcarchive/Products/Library/Frameworks/#{configuration.project.name}.framework' "
  end

  output_file = "#{configuration.directories.output}/#{configuration.project.name}.xcframework"

  Dir.chdir("..") do
    FileUtils.remove_dir(output_file) if File.directory?(output_file)

    # Create XCFramework from each framework archive
    sh("set -o pipefail && xcodebuild -create-xcframework #{inputs} -output '#{output_file}' | xcpretty")
  end
end

private_lane :make_artefact do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:framework_suffix]
    raise "No environment specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  configuration = options[:configuration]
  framework_suffix = options[:framework_suffix]
  environment = options[:environment]
  version = options[:version]

  # Source URL for Cocoapods
  source_url = ""

  case environment
  when "development", "devc", "staging", "prod"
    # Artifactory
    source_url = "#{configuration.artifactory.url}/sdk-cocoapods-#{environment}/#{configuration.project.name}#{framework_suffix}"
  when "beta", "release"
    #S3 /beta
    source_url = "#{configuration.amazon.url}/#{environment}/#{configuration.amazon.project_key}/#{version}"
  end

  # Build the frameworks for multiple SDKs
  build_frameworks configuration: configuration, version: version

  # Package the framework before sending it
  combine_frameworks configuration: configuration, framework_suffix: framework_suffix

  # Update Podspec
  update_podspec configuration: configuration, framework_suffix: framework_suffix, version: version, source_url: source_url

  create_artefact configuration: configuration, version: version, framework_suffix: framework_suffix
end

private_lane :create_artefact do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:framework_suffix]
    raise "No framework suffix specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  configuration = options[:configuration]
  framework_suffix = options[:framework_suffix]
  version = options[:version]

  archive_filename = get_archive_filename(configuration.project.name, framework_suffix, version)
  podspec_filename = get_podspec_filename(configuration.project.name, framework_suffix)

  Dir.chdir("..") do
    sh("tar -czvf #{configuration.directories.output}/#{archive_filename} -C #{configuration.directories.output} #{configuration.project.name}.xcframework #{podspec_filename}")
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

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:source_url]
    raise "No source url specified!".red
  end

  configuration = options[:configuration]
  framework_suffix = options[:framework_suffix]
  version = options[:version]
  source_url = options[:source_url]

  template_podspec_file = "#{configuration.project.name}.podspec.json"
  output_file = get_podspec_filename(configuration.project.name, framework_suffix)
  archive_filename = get_archive_filename(configuration.project.name, framework_suffix, version)

  content = JSON.parse(IO.read("./templates/#{template_podspec_file}"))

  # Update JSON fields
  content["name"] = configuration.project.name + framework_suffix
  content["version"] = version
  content["vendored_frameworks"] = "#{configuration.project.name}.xcframework"
  content["source"]["http"] = source_url + "/#{archive_filename}"

  # Write the podspec to output
  Dir.chdir("..") do
    File.open("#{configuration.directories.output}/#{output_file}", "w") do |file|
      file.write(JSON.pretty_generate(content))
    end
  end
end

private_lane :push_to_cocoapods_repository do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:framework_suffix]
    raise "No framework suffix specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  configuration = options[:configuration]
  framework_suffix = options[:framework_suffix]
  version = options[:version]

  cocoapods_directory = "#{configuration.directories.output}/cocoapods"
  podspec_filename = get_podspec_filename(configuration.project.name, framework_suffix)

  Dir.chdir("..") do
    FileUtils.remove_dir(cocoapods_directory) if File.directory?(cocoapods_directory)

    # Create Git temp directory
    sh("mkdir -p #{cocoapods_directory}")

    # Checkout private Cocoapods repository
    sh("git clone --depth=50 #{configuration.cocoapods.url} #{cocoapods_directory}")

    # Create new version directory
    new_version_directory = "#{cocoapods_directory}/#{configuration.project.name}#{framework_suffix}/#{version}"
    sh("mkdir -p #{new_version_directory}")

    # Copy update podspec to temp directory
    sh("cp '#{configuration.directories.output}/#{podspec_filename}' '#{new_version_directory}'")

    # Add file
    Dir.chdir("#{cocoapods_directory}") do
      sh("git add .")
      sh("git commit -m '#{configuration.project.name}#{framework_suffix} (#{version})'")
      sh("git push origin master")
    end
  end
end

### ARTIFACTORY

desc "Upload archive to Artifactory"
private_lane :upload_artefact_artifactory do |options|
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

  configuration = options[:configuration]
  framework_suffix = options[:framework_suffix]
  environment = options[:environment]
  version = options[:version]

  archive_filename = get_archive_filename(configuration.project.name, framework_suffix, version)
  
  if !ENV["ARTIFACTORY_TOKEN"]
    raise "ARTIFACTORY_TOKEN value is missing".red
  end

  artifactory(
    endpoint: configuration.artifactory.url,
    api_key: ENV["ARTIFACTORY_TOKEN"],
    file: "#{configuration.directories.output}/#{archive_filename}",
    repo: "sdk-cocoapods-#{environment}",
    repo_path: "/#{configuration.project.name}#{options[:framework_suffix]}/#{archive_filename}",
  )
end

### AMAZON S3

private_lane :prepare_amazon_artefacts do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:framework_suffix]
    raise "No framework suffix specified!".red
  end

  configuration = options[:configuration]
  environment = options[:environment]
  version = options[:version]
  framework_suffix = options[:framework_suffix]

  amazon_directory = "#{configuration.directories.output}/amazon/#{environment}/#{configuration.amazon.project_key}/#{version}"
  archive_filename = get_archive_filename(configuration.project.name, framework_suffix, version)
  podspec_filename = get_podspec_filename(configuration.project.name, framework_suffix)

  Dir.chdir("..") do
    # Create Amazon directory
    sh("mkdir -p #{amazon_directory}")

    # Copy archive and Podspec
    sh("cp '#{configuration.directories.output}/#{archive_filename}' '#{amazon_directory}'")
    sh("cp '#{configuration.directories.output}/#{podspec_filename}' '#{amazon_directory}'")
  end
end
