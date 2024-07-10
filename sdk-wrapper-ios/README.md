# Ogury

![Version](https://img.shields.io/badge/Version-4.3.0-blue.svg?style=for-the-badge)
![iOS](https://img.shields.io/badge/iOS-10+-lightgrey.svg?style=for-the-badge)
![iPadOS](https://img.shields.io/badge/iPadOS-10+-lightgrey.svg?style=for-the-badge)

`OgurySdk` is a framework that wraps every other **Ogury** frameworks.

## Summary

- [Installation](#installation)
- [Setting up the project](#setting-up-the-project)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Cocoapods

To integrate `OgurySdk` into your project, add the following line in your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'OgurySdk'
end
```

Then run the following command:

`$ pod install`

## Setting up the project

### Artifactory

Before setting up the project, you need to setup the internal artifactory repository.

First install the cocoa-art plugin as described in the [Artifactory documentation](https://www.jfrog.com/confluence/display/JFROG/CocoaPods+Repositories#CocoaPodsRepositories-Usingcocoapods-art).

Then configure our internal repositories for devc, staging and prod environment:
```
pod repo-art add HttpsOguryJfrogIoArtifactoryApiPodsSdkCocoapodsDevc https://ogury.jfrog.io/artifactory/api/pods/sdk-cocoapods-devc
pod repo-art add HttpsOguryJfrogIoArtifactoryApiPodsSdkCocoapodsStaging https://ogury.jfrog.io/artifactory/api/pods/sdk-cocoapods-staging
pod repo-art add HttpsOguryJfrogIoArtifactoryApiPodsSdkCocoapodsProd https://ogury.jfrog.io/artifactory/api/pods/sdk-cocoapods-prod
```

### Cocoapods

Install dependencies depending on the environment:

```
bundle exec fastlane generate_podfile environment:'release'
bundle exec pod install --repo-update
```

Supported environments are: 'devc', 'staging', 'prod', 'beta', 'release'.

## Contributing

Check [CONTRIBUTING](https://github.com/Ogury/sdk-wrapper-ios/blob/master/CONTRIBUTING.md) for more details on how you can contribute to the project.

## License

See [LICENSE](https://github.com/Ogury/sdk-wrapper-ios/blob/master/LICENSE) for more details.
