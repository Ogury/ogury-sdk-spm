# Ogury SDK-iOS Jenkins walkthrough

This file aim to help you understand the various options you can use with Jenkins to generate your frameworks.

You can direclty jump to the [tag examples section](#tag-examples) if needed.

## Stages
The Jenkinsfile has several stages

<a name="build"></a>
### Build
Whenever a commit or a tag are pushed, this stage tries to build the framework to check if it compiles.

###### Underlying Fastlane command

```
bundle exec fastlane build environment:'prod' artifactory:false targetThreshold:all killModeEnabled:false
```
<a name="build-options"></a>
The options are [^fastlaneOptions] : 

- **environment**: The target environment to deploy the framework to
- **artifactory**: Specifies wether to use local or external dependencies
- **targetThreshold**: Defines the dependency level for the Cocoapod file and compilation options [^2]. Can be one of `core`, `ads` or `all` (default value if not provided)
- **killModeEnabled**: specifies wether to allow access to `WEBVIEW_KILL_MODE` on `OguryAds`

[^fastlaneOptions]: see [Deployments section](#Deployments) to have the list of possible values
[^2]: `OguryCore` has no dependecy, `OguryAds` depends on `core` and `OgurySdk` depends on `ads`. In order to be able to compile and generate dependecies properly, the `threshold` option defines the highest dependency to handle: `core`, `ads` or `all`

### Test Dev
This stage will run the tests in `Prod` environment

###### Underlying Fastlane command


```
bundle exec fastlane test environment:prod
```

### Test Prod
This stage will run the tests in `Release` environment

###### Underlying Fastlane command


```
bundle exec fastlane test environment:release
```

<a name="Deployments"></a>
### Deployments
This stage will analyse the tag constitution and deploy the framework where it should.

Each tag must contain at least 4 informations : 

 - The type of deployment
 - The SDK that should be deployed
 - The SDK Version to create the artifactory item
 - The build Version to create the artifactory item

#### Type of deployment
You can choose between `internal`, `beta` or `release` tags. The tag **must** start with one of these values.

<a name="sdk-to-deploy"></a>
#### SDK to deploy
You can choose between `core`, `ads` or `wrapper` tags. The tag **must** have one of these values after the deployment type.

#### SDK Version
This part **must** respect the **semver** rules `x.y.z`

#### Build Version
This part can be anything, but we do encourage you to use `description-x.x.x`. It will help you find the good binary on artifactory

#### External or internal dependecy
The SDKs can be compiled using local or remote (cocoapod or artifactory) dependency. If you don't supply any information, the compilation will use `local` dependencies. If you want your SDKs to use the various versions described in the `Configuration.rb` file, then provide `-art` in the tag after the [SDK to deploy](#sdk-to-deploy)

Behind the scene, the Xcode project has each target duplicated in order to handle local/remote frameworks

#### Kill Mode
The ads SDK comes with a private feature that allows you to simulate a webViewKill and exposes the ad's webview in order to kill it (physicalk device only). Note that this option only applies to `OguryAds` SDK

- In `DEBUG` mode, this feature is activated. 
- In `BETA` mode, this feature can be activated using the `-killModeEnabled` tag option after the [SDK to deploy](#sdk-to-deploy) or the `-art` option if supplied
- In `RELEASE` mode, this feature is always deactivated. 

Begind the scene, the Xcode project uses a Preprocessor macro `KILL_MODE_ENABLED`

#### QA Mode
The new test application comes with a compilation option that allows you to create a test application with QA settings (so far, only the import method is set to `text` inseatd of `file` to ease its use with testsigma. 

Begind the scene, the Xcode project uses a Swift flag `QA_MODE=1` to handle its settings at compile time.

###### Underlying Fastlane commands

```
bundle exec fastlane deploy_core_framework environment:beta tag:beta-core-3.9.9-NewCITests-1.0.0 artifactory:false killModeEnabled:false
bundle exec fastlane deploy_core_podspec environment:beta tag:beta-core-3.9.9-NewCITests-1.0.0 artifactory:false
```
The options are the same as the [build stage](#build-options).

One extra option is available here: `dry_run: true` that will test every step except the upload phase to S3.

<a name="tag-examples"></a>
### Tag examples
Here are a few tags and their meaning regarding the options.

- ***internal-core-3.0.0-ci-1.0.1*** will produce a `OguryCore` SDK on artifactory only, in `prod` environment, and you can retrieve it on JFrog at `sdk-cocoapods-prod/OguryCore-Prod/OguryCore-Prod-3.0.0-ci-1.0.1.tar.gz`. It will be compiled using local dependencies and all options will be the default ones. 
- ***internal-ads-killModeEnabled-3.9.9-ci-1.0.1*** will produce a `OguryAds` SDK on artifactory only, in `prod` environment, and you can retrieve it on JFrog at `sdk-cocoapods-prod/OguryAds-Prod/OguryAds-Prod-3.9.9-ci-1.0.1.tar.gz`. It will be compiled with local dependecies and have the `KILL_MODE_ENABLED` option ON.
- ***beta-ads-art-killModeEnabled-3.9.9-ci-1.0.2*** will produce a `OguryAds` SDK on Amazon S3 only, in `beta` environment, and you can [retrieve it on s3](https://eu-west-1.console.aws.amazon.com/s3/buckets/ogury-sdk-binaries?region=eu-west-1&bucketType=general&prefix=beta/&showversions=false) at `ogury-sdk-binaries/beta/ads-ios/3.9.9/`. It will be compiled with external dependecies (i.e. artifactory) and have the `KILL_MODE_ENABLED` option ON. Note that in `release` of `beta` environment, the CI does not care about the version set in the tag but uses the internal version declared in the `configuration.xcconfig` file for each project. It will also upload a `podspec`to [Ogury cocoapod beta repository](https://github.com/Ogury/ogury-cocoapods-repository/tree/master/)
- ***release-wrapper-5.0.0-rc1.1.0.0*** will release the official Release SDK onto S3 (like the `beta` tag)

##Test Applications
In order to deploy test applications, here are the tags to use : 

- your tag must start with `internal-testApp@`
- it **must** be followed by the app(s) you want to deploy :
	- `all` will deploy all test app
	- `ogury` will deploy devc, staging and prod Ogury test application
	- `mediation` will deploy max, adMob and unity test applications
	- or you can deploy a single application (referenced inside the `Configuration.rb` file as follows: 
		- `prodTestApp`
		- `devcTestApp`
		- `stagingTestApp`
		- `maxTestApp`
		- `adMobTestApp`
		- `unityTestApp`
		- `prebidTestApp`
- you can specify qaMode, art mode and killMode as well 

Here are some tag examples

- **internal-testApp@all-1.0.0-rc1.0.0** 
- **internal-testApp@ogury-1.0.0-rc1.0.0** 
- **internal-testApp@testAppProd-killModeEnabled-qaMode-1.0.0-rc1.0.0** 
 