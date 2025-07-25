def get_framework_suffix(environment)
    case environment
    when "development", "devc"
      return "-Devc"
    when "staging"
      return "-Staging"
    when "prod"
      return "-Prod"
    when "beta"
      return "-Beta"
    when "release"
      return ""
    end
end

def get_archive_filename(project_name, framework_suffix, version)
    return "#{project_name}#{framework_suffix}-#{version}.tar.gz"
end

def get_podspec_filename(project_name, framework_suffix)
    return "#{project_name}#{framework_suffix}.podspec.json"
end

def get_artifactory_repository_url(environment, artifactory_url)
  case environment
  when "devc", "staging", "prod"
    return "#{artifactory_url}/api/pods/sdk-cocoapods-#{environment}"
  else
    return nil
  end
end

def get_artifactory_repository_name(environment)
  case environment
  when "devc", "staging", "prod"
    return "sdk-cocoapods-#{environment}"
  else
    return nil
  end
end

# Get the version of the SDK to deploy
# For beta and production releases, the version number is taken from the project configuration.
# For internal releases, the version is retrieved from the tag instead.
def get_version(environment, xcodeproj, target, tag)
  project_version = get_version_number(
    xcodeproj: xcodeproj,
    target: target
  )
  
  if ["beta", "release"].include? environment
    return project_version
  end

  tag_version = tag[/internal-(?:[\w-]+?)-(\d+\.\d+\.\d+(?:-(?:rc|alpha)(?:\.[\w]+)?(?:\.\d+)?)?)/, 1]

  return tag_version
end


def get_module_version(environment, internal_version, beta_version, staging_version)
  case environment
  when "devc", "staging", "prod"
    return internal_version
  when "beta"
    return beta_version
  when "release"
    return staging_version
  end
end

private_lane :setup_xcode do
  # Run the defaults write command
  sh("defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES")

  # Additional setup steps can be added here
end
