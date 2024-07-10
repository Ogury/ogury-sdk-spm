private_lane :deploy_on_artifactory do |options|
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

  puts "Deploying OguryAds on artifactory".cyan
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(configuration.project.adsName, framework_suffix, version)

  artifactory(
    endpoint: configuration.artifactory.url,
    api_key: ENV["ARTIFACTORY_TOKEN"],
    file: "#{configuration.directories.output}/#{archive_filename}",
    repo: "sdk-cocoapods-#{environment}",
    repo_path: "/#{configuration.project.adsName}#{framework_suffix}/#{archive_filename}",
  )
end

private_lane :deploy_card_lib_on_artifactory do |options|
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

  puts "Deploying AdsCardLibrary on artifactory".cyan
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(configuration.project.adsLibraryName, framework_suffix, version)

  artifactory(
    endpoint: configuration.artifactory.url,
    api_key: ENV["ARTIFACTORY_TOKEN"],
    file: "#{configuration.directories.output}/#{archive_filename}",
    repo: "sdk-cocoapods-#{environment}",
    repo_path: "/#{configuration.project.adsLibraryName}#{framework_suffix}/#{archive_filename}",
  )
end

desc "deploy in amazon"
private_lane :deploy_on_amazon do |options|
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
  environment = options[:environment]
  version = options[:version]

  framework_suffix = get_framework_suffix(environment)

  amazon_directory = "#{configuration.directories.output}/amazon/#{environment}/#{configuration.amazon.project_key}/#{version}"
  archive_filename = get_archive_filename(configuration.project.adsName, framework_suffix, version)
  podspec_filename = get_podspec_filename(configuration.project.adsName, framework_suffix)

  Dir.chdir("..") do
    sh("mkdir -p '#{amazon_directory}'")
    sh("cp '#{configuration.directories.output}/#{archive_filename}' '#{amazon_directory}'")
    sh("cp '#{configuration.directories.output}/#{podspec_filename}' '#{amazon_directory}'")
  end
end

desc "Push the supplied podspec to the specified Cocoapod repository"
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
  podspec_filename = get_podspec_filename(configuration.project.adsName, framework_suffix)

  Dir.chdir("..") do
    FileUtils.remove_dir(cocoapods_directory) if File.directory?(cocoapods_directory)
    
    # Create Git temp directory
    sh("mkdir -p '#{cocoapods_directory}'")

    # Checkout private Cocoapods repository
    sh("git clone --depth=50 #{configuration.cocoapods.url} '#{cocoapods_directory}'")

    # Create new version directory
    new_version_directory = "#{cocoapods_directory}/#{configuration.project.adsName}#{framework_suffix}/#{version}"
    sh("mkdir -p '#{new_version_directory}'")

    # Copy update podspec to temp directory
    sh("cp '#{configuration.directories.output}/#{podspec_filename}' '#{new_version_directory}'")

    # Add file
    Dir.chdir("#{cocoapods_directory}") do
      sh("git add .")
      sh("git commit -m '#{configuration.project.adsName}-#{framework_suffix} (#{version})'")
      sh("git push origin master")
    end
  end
end
