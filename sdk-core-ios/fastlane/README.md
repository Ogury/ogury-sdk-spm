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

### ios build

```sh
[bundle exec] fastlane ios build
```

Build framework for different SDKs

### ios test

```sh
[bundle exec] fastlane ios test
```

Build and test framework for different SDKs

### ios analyse

```sh
[bundle exec] fastlane ios analyse
```

Analyse the test result for the framework

### ios deploy_artefact

```sh
[bundle exec] fastlane ios deploy_artefact
```

Proceed to deploy a new version of the framework for the specified environment

### ios deploy_podspec

```sh
[bundle exec] fastlane ios deploy_podspec
```

Proceed to deploy a new version of the framewok for the specified environment

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
