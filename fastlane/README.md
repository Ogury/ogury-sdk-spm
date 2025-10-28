fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### spm

```sh
[bundle exec] fastlane spm
```

Updates the package.swift file, upload it to spm repo, create a release branch, a tag and a release version

### update_spm_package

```sh
[bundle exec] fastlane update_spm_package
```

Update Ogury Package.swift with latest binaries & checksums

### build_spm_package

```sh
[bundle exec] fastlane build_spm_package
```

Build the Ogury SPM package for validation

### push_spm_package

```sh
[bundle exec] fastlane push_spm_package
```

Push updated Package.swift to a release branch and open PR on ogury-sdk-spm

### create_spm_release

```sh
[bundle exec] fastlane create_spm_release
```

Tag and create a GitHub release for ogury-sdk-spm

### configure_git_remotes

```sh
[bundle exec] fastlane configure_git_remotes
```

Ensure both 'official' and 'private' Git remotes exist for OgurySdk-SPM

### prepare_for_deployment

```sh
[bundle exec] fastlane prepare_for_deployment
```



### prepare_core_for_deployment

```sh
[bundle exec] fastlane prepare_core_for_deployment
```



### prepare_ads_for_deployment

```sh
[bundle exec] fastlane prepare_ads_for_deployment
```



### prepare_omid_for_deployment

```sh
[bundle exec] fastlane prepare_omid_for_deployment
```



### prepare_wrapper_for_deployment

```sh
[bundle exec] fastlane prepare_wrapper_for_deployment
```



### upload_artifacts_to_s3

```sh
[bundle exec] fastlane upload_artifacts_to_s3
```



----


## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```



### ios update_internal_cocoapods

```sh
[bundle exec] fastlane ios update_internal_cocoapods
```

Install CocoaPods internal repository for environment and update it.

### ios generate_podfile

```sh
[bundle exec] fastlane ios generate_podfile
```

Generates a new Podilfe based on the environment and the configuration file

### ios test

```sh
[bundle exec] fastlane ios test
```

test framework for different SDKs

### ios deploy_frameworks

```sh
[bundle exec] fastlane ios deploy_frameworks
```



### ios deploy_core_framework

```sh
[bundle exec] fastlane ios deploy_core_framework
```

Proceed to deploy a new version of a framewok passed as parameter for the specified environment

### ios deploy_ads_framework

```sh
[bundle exec] fastlane ios deploy_ads_framework
```

Proceed to deploy a new version of a framewok passed as parameter for the specified environment

### ios deploy_wrapper_framework

```sh
[bundle exec] fastlane ios deploy_wrapper_framework
```

Proceed to deploy a new version of a framewok passed as parameter for the specified environment

### ios generate_test_app

```sh
[bundle exec] fastlane ios generate_test_app
```

Proceed to deploy a new version of a framewok passed as parameter for the specified environment

### ios deploy_podspec

```sh
[bundle exec] fastlane ios deploy_podspec
```

Proceed to deploy a new version of the framewok for the specified environment

### ios deploy_core_podspec

```sh
[bundle exec] fastlane ios deploy_core_podspec
```

Proceed to deploy a new version of the core framewok for the specified environment

### ios deploy_ads_podspec

```sh
[bundle exec] fastlane ios deploy_ads_podspec
```

Proceed to deploy a new version of the ads framewok for the specified environment

### ios deploy_wrapper_podspec

```sh
[bundle exec] fastlane ios deploy_wrapper_podspec
```

Proceed to deploy a new version of the ads framewok for the specified environment

### ios deploy_spm

```sh
[bundle exec] fastlane ios deploy_spm
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
