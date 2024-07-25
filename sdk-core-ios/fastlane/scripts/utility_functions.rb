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

# Get the version of the SDK to deploy
# For beta and production releases, the version number is taken from the project configuration.
# For internal releases, the version is retrieved from the tag instead.
# The major, minor and release of the tag must match the version of the project
# otherwise the method will throw an exception.
def get_version(environment, xcodeproj, target, tag)
  project_version = get_version_number(
    xcodeproj: xcodeproj,
    target: target
  )
  
  if ["beta", "release"].include? environment
    return project_version
  end

  tag_version = tag[/internal-(.+)/, 1]

  return tag_version
end

def get_generic_destination(sdk)
  case sdk
  when "iphonesimulator"
    return "generic/platform=iOS Simulator"
  when "iphoneos"
    return "generic/platform=iOS"
  end
  return ""
end
