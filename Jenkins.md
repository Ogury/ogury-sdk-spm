# Ogury SDK-iOS Jenkins walkthrough

This file aim to help you understand the various options you can use with Jenkins to generate your frameworks.

You can direclty jump to the [tag section](#tag-examples) is needed.

## Stages
The Jenkinsfile has several stages

### Build
Whenever a commit or a tag are pushed, this stage tries to build the framework to check if it compiles.

### Test Dev
This stage will run the tests in `Prod` environment

### Test Prod
This stage will run the tests in `Release` environment

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

<a name="tag-examples"></a>
### Tag examples
Here are a few tags and their meaning regarding the options.

- ***internal-core-3.0.0-ci-1.0.1*** will produce a `OguryCore` SDK on artifactory only, in `prod` environment, and you can retrieve it on JFrog at `sdk-cocoapods-prod/OguryCore-Prod/OguryCore-Prod-3.0.0-ci-1.0.1.tar.gz`. It will be compiled using local dependencies and all options will be the default ones. 
- ***internal-ads-killModeEnabled-3.9.9-ci-1.0.1*** will produce a `OguryAds` SDK on artifactory only, in `prod` environment, and you can retrieve it on JFrog at `sdk-cocoapods-prod/OguryAds-Prod/OguryAds-Prod-3.9.9-ci-1.0.1.tar.gz`. It will be compiled with local dependecies and have the `KILL_MODE_ENABLED` option ON.
- ***beta-ads-art-killModeEnabled-3.9.9-ci-1.0.2*** will produce a `OguryAds` SDK on Amazon S3 only, in `beta` environment, and you can [retrieve it on s3](https://eu-west-1.console.aws.amazon.com/s3/buckets/ogury-sdk-binaries?region=eu-west-1&bucketType=general&prefix=beta/&showversions=false) at `ogury-sdk-binaries/beta/ads-ios/3.9.9/`. It will be compiled with external dependecies (i.e. artifactory) and have the `KILL_MODE_ENABLED` option ON. Note that in `release` of `beta` environment, the CI does not care about the version set in the tag but uses the internal version declared in the `configuration.xcconfig` file for each project. It will also upload a `podspec`to [Ogury cocoapod beta repository](https://github.com/Ogury/ogury-cocoapods-repository/tree/master/)
- ***release-wrapper-5.0.0-rc1.1.0.0*** will release the official Release SDK onto S3 (like the `beta` tag)
