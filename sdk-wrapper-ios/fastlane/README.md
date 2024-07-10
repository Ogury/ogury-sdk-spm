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



### ios convert_code_coverage

```sh
[bundle exec] fastlane ios convert_code_coverage
```

Convert the code coverage of the project

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



### ios analyse

```sh
[bundle exec] fastlane ios analyse
```



### ios generate_test_app

```sh
[bundle exec] fastlane ios generate_test_app
```



### ios deploy_artefact

```sh
[bundle exec] fastlane ios deploy_artefact
```

Proceed to deploy a new version of the framewok for the specified environment

### ios deploy_podspec

```sh
[bundle exec] fastlane ios deploy_podspec
```

Proceed to deploy a new version of the framewok for the specified environment

### ios update_internal_cocoapods

```sh
[bundle exec] fastlane ios update_internal_cocoapods
```

Install cocoapods internal repository for environment and update it.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
