# Ogury SDK-iOS Workspace

The workspace includes the following projects:

- **OguryCore**
- **OguryAdsSDK**
- **OguryWrapper**
- **LegacyTestApp**
- **AdsTestApp**
- **AdsCardLibrary**

## Prerequisites

Before you begin, make sure you have the following installed on your macOS system:

1. **Ruby 2.7.7**: This is required for running certain scripts and tools. You can install it via `rvm`.
2. **Fastlane**: A tool for automating tasks in your development workflow.
3. **CocoaPods**: A dependency manager for Swift and Objective-C projects.

### Installing Prerequisites

1. **Install RVM (Ruby Version Manager) and Ruby 2.7.7**

   Open your terminal and run the following commands:

   ```bash
   \curl -sSL https://get.rvm.io | bash -s stable --ruby=2.7.7
   source ~/.rvm/scripts/rvm
   rvm use 2.7.7 --default
   ```

2. **Install Fastlane**

   Once Ruby is installed, install Fastlane by running:

   ```bash
   gem install fastlane -NV
   ```

3. **Install CocoaPods**

   Finally, install CocoaPods by running:

   ```bash
   gem install cocoapods
   ```

## Setting Up the Project

After you have installed the prerequisites, follow these steps to set up and run the project:

1. **Navigate to the Project Directory**

   Open your terminal and navigate to the root directory of the project.

2. **Generate the Podfile**

   Run the following command to generate the Podfile for the environment you are targeting:

   ```bash
   bundle exec fastlane generate_podfile environment:prod
   ```

3. **Install Pods**

   Once the Podfile is generated, install the required dependencies by running:

   ```bash
   pod install
   ```

4. **Open the Workspace**

   After the pods are installed, open the workspace using Xcode:

   ```bash
   open OgurySdks.xcworkspace
   ```

5. **Build and Run**

   Finally, build and run the project using Xcode. This project was last built and tested on **Xcode 15.4**.

6. **Build Options**

   Here are the various build options handled by this project
   - `-D QA_MODE`  (Other Swift flags of `AdsTestApp` project) : builds the test application with these options :
      - Default import method is `Text` instead of `File`
   - `KILLMODE=1` (Preprocessor Macros of `OguryAds`) allows release SDK to handle the kill webview commands (simulate and crash)
   

## Development concerns

### Load settings in test app at first start

When the test application starts, it will try to load various `.settings` files stored in the project.
For the development applications (devc/stag/prod), the file is located at `${SRC_ROOT}/AdsTestApp/Controllers/Settings/Dev App`. When more test application will come (OMID, certifications, etc.), we will create new folders under `Settings` and add the same files as below for each target.

If the UserDefaut is empty, the test app will try to load thoses files in order :

1. `Custom.settings`. This file is to be used to locally load custom settings and ads (formely known as the `Zak's feature` ❤️). You can use this file to load custom settings and ads at start. It is also used by the CI to inject custom settings at build time
2. `Default-qa.settings` : if the QA mode is activated, then it will try to load this file
3. `Default.settings` finally, the default file is loaded

```
⚠️⚠️⚠️ ALWAYS LEAVE THE CUSTOM.SETTINGS FILE EMPTY WHEN YOU COMMIT ⚠️⚠️⚠️
```

### Hidden settings
The `settings` node contains a hidden, not exported node that controls the display of various features

```
"permissions" :  {
   "settings" : true,   // if true, settings button is displayed
   "logs" : true,       // if true, logs button is displayed
   "add" : true,        // if true, add buttons are displayed
   "export" : true,     // if true, export features are displayed
   "bulkMode" : true    // if true, buklm mode button is displayed
}
```


## Additional Notes

- **macOS Requirement**: This project requires a macOS environment to build and run.
- **Xcode Version**: Ensure you are using Xcode version 15.4 or later to avoid compatibility issues.