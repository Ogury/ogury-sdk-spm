fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios analyse_source_code

```sh
[bundle exec] fastlane ios analyse_source_code
```



### ios prepare_for_deployment

```sh
[bundle exec] fastlane ios prepare_for_deployment
```



### ios generate_podfile

```sh
[bundle exec] fastlane ios generate_podfile
```



### ios build

```sh
[bundle exec] fastlane ios build
```



### ios test

```sh
[bundle exec] fastlane ios test
```

test framework for different SDKs

### ios analyse

```sh
[bundle exec] fastlane ios analyse
```

Analyse the test result for the framework

### ios generate_test_app

```sh
[bundle exec] fastlane ios generate_test_app
```

test framework for different SDKs

### ios deploy_framework

```sh
[bundle exec] fastlane ios deploy_framework
```

Proceed to deploy a new version of the framewok for the specified environment

### ios deploy_podspec

```sh
[bundle exec] fastlane ios deploy_podspec
```

Proceed to deploy a new version of the podspec for the specified environment

### ios update_internal_cocoapods

```sh
[bundle exec] fastlane ios update_internal_cocoapods
```

Install cocoapods internal repository for environment and update it.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
