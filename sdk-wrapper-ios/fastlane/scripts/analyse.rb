lane :analyse_source_code do |options|
  if !options[:login]
    raise "No sonar login specified!".red
  end

  if options[:pull_request_branch] and options[:pull_request_base] and options[:pull_request_key]
    sonar(
      sonar_login: options[:login],
      project_language: "objc",
      pull_request_branch: options[:pull_request_branch],
      pull_request_base: options[:pull_request_base],
      pull_request_key: options[:pull_request_key]
    )
  else
    sonar(
      sonar_login: options[:login],
      project_language: "objc"
    )
  end
end

desc "Convert the code coverage of the project"
lane :convert_code_coverage do |options|
  if !options[:configuration]
    raise "No configuration specified!".red
  end

  configuration = options[:configuration]

  Dir.chdir("..") do
    if !Dir.exist?(configuration.directories.output)
      sh("mkdir '#{configuration.directories.output}'")
    end

    sh("bash ./fastlane/scripts/xccov-to-sonarqube-generic.sh  #{configuration.directories.test_derived_data}/Logs/Test/*.xcresult/ > '#{configuration.directories.output}/sonarqube-generic-coverage.xml'")
  end
end
