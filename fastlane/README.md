fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

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



### prepare_wrapper_for_deployment

```sh
[bundle exec] fastlane prepare_wrapper_for_deployment
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

Install cocoapods internal repository for environment and update it.

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

### ios deploy_framework

```sh
[bundle exec] fastlane ios deploy_framework
```

Proceed to deploy a new version of a framewok passed as parameter for the specified environment

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

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
