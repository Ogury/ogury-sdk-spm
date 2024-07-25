# Contributing

## Summary

- [Setup](#setup)
- [Branching Model](#branching-model)
- [Commits](#commits)
- [Release](#release)
  - [Continuous Integration](#continuous-integration)
  - [Manual release](#manual-release)

## Setup

To get started on contributing on the project you'll need to follow the steps:

- Install the latest stable version of **Xcode**
- Clone this repository from **GitHub**

If you're interested in running the CI actions locally, follow those additional steps:

- Install `rbenv` from the official **GitHub** [repository](https://github.com/rbenv/rbenv)
- Install the Ruby version specified within the `.ruby-version` file at the root directory
- Install `bundler` from the official [website](https://bundler.io)
- Run `bundle install` from the root directory

You can check the `fastlane/fastfile` configuration file to see which lanes are available to use.

We recommend the usage of the following useful tools:

- [Visual Studio Code](https://code.visualstudio.com)
- [iTerm2](https://iterm2.com)
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)

## Branching model

The current branching model is specified [here](https://confluence.ogury.io/pages/viewpage.action?spaceKey=MC2&title=SDK+Developer+Best+Practice).

Every single change that targets the main branches (master, develop) can only be merged through a pull request.

## Commits

Before commiting anything to you branch, make sure to add relevant message and description to your commit.

If you need to some insights on how to actually do this, here's some very interesting readings:

- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit)
- [Anatomy of a “Good” commit message](https://medium.com/@andrewhowdencom/anatomy-of-a-good-commit-message-acd9c4490437)

## Release

Before performing any release, it is mandatory to update the marketing version and the bundle version located in the `Configurations/Configuration.xcconfig` file.

### Continuous Integration

The project is relying of **Jenkins** to perform the continuous integration process. **Jenkins** is reponsible for uploading the artefacts to the right platforms (**GitHub**, **Artifactory**, **Amazon S3**).

In order to perform a release locally, you can use the following command:

`bundle exec fastlane deploy_framework environment:"ENVIRONMENT" version:"VERSION"`

Where:

- `ENVIRONMENT` is the environment you're building for [`devc`, `beta`, `release`]
- `VERSION` is the version of the artefact you want to create

To perform such command you'll need to have setup your machine in order to be capable for it to clone / push to GitHub for the Podspec.
