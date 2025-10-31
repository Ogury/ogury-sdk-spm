private_lane :deploy_on_private_cocoapods do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  if !options[:version]
    raise "No version specified!".red
  end

  if !options[:environment]
    raise "No environment specified!".red
  end

  if !options[:target]
    raise "No target specified!".red
  end

  configuration = options[:configuration]
  version = options[:version]
  environment = options[:environment]
  target = options[:target]

  puts "Deploying #{target.publicName} on s3".cyan
  framework_suffix = get_framework_suffix(environment)
  archive_filename = get_archive_filename(target.publicName, framework_suffix, version)

  s3_bucket = configuration.deployment.internal.s3.bucket
  case environment
  when "devc", "staging", "prod"
    s3_bucket = configuration.deployment.internal.s3.bucket
  when "beta", "release"
    s3_bucket = configuration.deployment.public.s3.bucket
  end

  # create cocoapods directory with path and upload id to s3
  cocoapods_directory = "#{configuration.directories.output}/cocoapods/#{environment}/#{target.publicName}/"
  Dir.chdir("..") do
    sh("mkdir -p '#{cocoapods_directory}'")
    sh("cp '#{configuration.directories.output}/#{archive_filename}' '#{cocoapods_directory}'")
  end
  upload_artifacts_to_s3(s3_bucket:s3_bucket, local_files:"#{configuration.directories.output}/cocoapods")

  # push the podspec
  push_podspec_to_private_repo(options) 
end

private_lane :push_podspec_to_private_repo do |options|
  configuration = options[:configuration] or raise "No configuration specified!".red
  environment = options[:environment] or raise "No environment specified!".red
  target = options[:target] or raise "No target specified!".red

  repo_name = 'sdk-internal'
  git_token = ENV["GIT_TOKEN"] || UI.user_error!("GIT_TOKEN not set")
  git_username = ENV["GIT_USERNAME"] || "weareogury"
  repo_url = "https://#{git_username}:#{git_token}@github.com/#{configuration.deployment.internal.cocoapods.url}"
  framework_suffix = get_framework_suffix(environment)
  podspec = "#{configuration.directories.output}/#{get_podspec_filename(target.publicName, framework_suffix)}"


  Dir.chdir("..") do
    #sh("pwd")
    UI.message("Linting #{podspec}...")
    sh("pod spec lint #{podspec} --verbose --allow-warnings --skip-tests --sources='sdk-internal'")
  
    # Check if repo is already added
    repo_list = sh("pod repo list", log: false)
    unless repo_list.include?(repo_name)
      UI.message("CocoaPods repo '#{repo_name}' not found. Adding it...")
      sh("pod repo add #{repo_name} #{repo_url}")
    else
      UI.message("CocoaPods repo '#{repo_name}' already exists.")
    end
    sh("pod repo push #{repo_name} #{podspec} --allow-warnings --skip-tests --sources='sdk-internal'")
  end
end

lane :upload_artifacts_to_s3 do |options|
  s3_bucket = options[:s3_bucket]
  local_files = options[:local_files]

  UI.user_error!("Missing s3_bucket") unless s3_bucket
  UI.user_error!("Missing local_files") unless local_files

  # Step 1: Assume the role and extract credentials
  Dir.chdir("..") do
    filename = File.basename(local_files)
    sh(%Q[aws s3 cp "#{local_files}" "s3://#{s3_bucket}/" --recursive])
  end
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
  
  if !options[:target]
    raise "No target specified!".red
  end

  configuration = options[:configuration]
  environment = options[:environment]
  version = options[:version]
  target = options[:target]

  framework_suffix = get_framework_suffix(environment)

  # /release/ios/5.1.0
  amazon_directory = "#{configuration.directories.output}/amazon/#{environment}/#{target.amazon}/#{version}"
  archive_filename = get_archive_filename(target.publicName, framework_suffix, version)
  podspec_filename = get_podspec_filename(target.publicName, framework_suffix)

  Dir.chdir("..") do
    sh("mkdir -p '#{amazon_directory}'")
    sh("cp '#{configuration.directories.output}/#{archive_filename}' '#{amazon_directory}'")
    sh("cp '#{configuration.directories.output}/#{podspec_filename}' '#{amazon_directory}'")
  end

  upload_artifacts_to_s3(s3_bucket:configuration.deployment.public.s3.bucket, local_files:"#{configuration.directories.output}/amazon/")
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
  
  if !options[:target]
    raise "No target specified!".red
  end

  configuration = options[:configuration]
  framework_suffix = options[:framework_suffix]
  version = options[:version]
  target = options[:target]

  cocoapods_directory = "#{configuration.directories.output}/cocoapods"
  podspec_filename = get_podspec_filename(target.publicName, framework_suffix)

  Dir.chdir("..") do
    FileUtils.remove_dir(cocoapods_directory) if File.directory?(cocoapods_directory)
    
    # Create Git temp directory
    sh("mkdir -p '#{cocoapods_directory}'")

    # Checkout private Cocoapods repository
    sh("git clone --depth=50 #{configuration.cocoapods.url} '#{cocoapods_directory}'")

    # Create new version directory
    new_version_directory = "#{cocoapods_directory}/#{target.publicName}#{framework_suffix}/#{version}"
    sh("mkdir -p '#{new_version_directory}'")

    # Copy update podspec to temp directory
    sh("cp '#{configuration.directories.output}/#{podspec_filename}' '#{new_version_directory}'")

    # Add file
    Dir.chdir("#{cocoapods_directory}") do
      sh("git add .")
      sh("git commit -m '#{target.publicName}-#{framework_suffix} (#{version})'")
      sh("git push origin master")
    end
  end
end
