  
@Library('ogury-jenkins-lib@v4.0.0') _

pipeline {
    agent {
        label 'macM2-worker'
    }

    environment {
        GIT_TOKEN = credentials('GIT_TOKEN')
        GIT_USERNAME = "weareogury"
        LC_ALL = 'en_US.UTF-8'
        PATH = "/usr/local/bin:~/.rvm/gems/ruby-2.7.7/wrappers:$PATH"
        RBENV_SHELL = 'zsh'
        SONAR_CLOUD_TOKEN = credentials('SONAR_CLOUD_TOKEN')
        ARTIFACTORY_TOKEN = credentials('ARTIFACTORY_TOKEN')
    }

    stages {

        stage('Setup') {
            steps {
                sh """#!/bin/zsh -l
                    bundle install
                    defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
                """
            }
        }

        stage('Build') {
            when {
                beforeAgent true
                not { changeRequest() }
            }

            steps {
                sh """#!/bin/zsh -l
                    source ~/.zshrc
                    rvm --default use 2.7.7
                """
                sh """#!/bin/zsh -l
                    source ~/.zshrc
                    bundle exec fastlane build environment:'prod'
                """
            }
        }

        stage('Test-Dev') {
            when {
                beforeAgent true
                changeRequest()
                not {
                    branch 'master'
                }
            }
            steps {
                sh """#!/bin/zsh -l
                    mkdir -p jenkins
                    bundle exec fastlane test environment:'prod'
                """
            }
        }

        stage('Test-Prod') {
            when {
                beforeAgent true
                anyOf {
                    branch 'master'
                    changeRequest target:'master'
                }
            }
            steps {
                sh """#!/bin/zsh -l
                    mkdir -p jenkins
                    bundle exec fastlane test environment:release
                """
            }
        }

        // sta

        stage('Deployment') {
            when {
                beforeAgent true
                buildingTag()
                not { changeRequest() }
            }
            stages {
                // deploy internal builds, both dev and release mode (i.e. uses maven dependencies instead of local ones)
                stage('Deploy Core Internal dev') {
                    when {
                        beforeAgent true
                        expression {
                            def tagPattern = ~/^internal-core-.*$/
                            return env.GIT_TAG ==~ tagPattern && !"${env.TAG_NAME}".split("-").contains("-art")
                        }
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:prod tag:${env.TAG_NAME}
                        """
                    }
                }
                stage('Deploy Core Internal With Cocoapod Dependencies') {
                    when {
                        beforeAgent true
                        tag "internal-core-art-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:prod tag:${env.TAG_NAME} artifactory:true
                        """
                    }
                }
                stage('Deploy Ads Internal dev') {
                    when {
                        beforeAgent true
                        expression {
                            def tagPattern = ~/^internal-ads-.*$/
                            return env.GIT_TAG ==~ tagPattern && !"${env.TAG_NAME}".split("-").contains("-art")
                        }
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:prod tag:${env.TAG_NAME}
                        """
                    }
                }
                stage('Deploy Ads Internal With Cocoapod Dependencies') {
                    when {
                        beforeAgent true
                        tag "internal-ads-art-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:prod tag:${env.TAG_NAME} artifactory:true
                        """
                    }
                }
                stage('Deploy Wrapper Internal dev') {
                    when {
                        beforeAgent true
                        expression {
                            // Check if the current tag matches the pattern "internal-wrapper-<digits separated by dots>-<description>"
                            def tagPattern = ~/^internal-wrapper-(\d+(\.\d+)*)-.*$/
                            return env.GIT_TAG ==~ tagPattern
                        }
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_wrapper_framework environment:prod tag:${env.TAG_NAME}
                        """
                    }
                }
                stage('Deploy wrapper Internal With Cocoapod Dependencies') {
                    when {
                        beforeAgent true
                        tag "internal-wrapper-art-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_wrapper_framework environment:prod tag:${env.TAG_NAME} artifactory:true
                        """
                    }
                }

                // deploy beta version, both dev and release mode
                stage('Deploy Core Beta dev') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        expression {
                            // Check if the current tag matches the pattern "internal-core-<digits separated by dots>-<description>"
                            def tagPattern = ~/^beta-core-(\d+(\.\d+)*)-.*$/
                            return env.GIT_TAG ==~ tagPattern
                        }
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:beta tag:${env.TAG_NAME}
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_core_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy Core Beta With Cocoapod Dependencies') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "beta-core-art-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:beta tag:${env.TAG_NAME} artifactory:true
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_core_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy Ads Beta dev') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        expression {
                            // Check if the current tag matches the pattern "internal-ads-<digits separated by dots>-<description>"
                            def tagPattern = ~/^beta-ads-(\d+(\.\d+)*)-.*$/
                            return env.GIT_TAG ==~ tagPattern
                        }
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:beta tag:${env.TAG_NAME}
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_ads_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy ads Beta With Cocoapod Dependencies') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "beta-ads-art-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:beta tag:${env.TAG_NAME} artifactory:true
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_ads_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy wrapper Beta dev') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        expression {
                            // Check if the current tag matches the pattern "internal-wrapper-<digits separated by dots>-<description>"
                            def tagPattern = ~/^beta-wrapper-(\d+(\.\d+)*)-.*$/
                            return env.GIT_TAG ==~ tagPattern
                        }
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_wrapper_framework environment:beta tag:${env.TAG_NAME}
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_wrapper_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy wrapper Beta With Cocoapod Dependencies') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "beta-wrapper-art-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_wrapper_framework environment:beta tag:${env.TAG_NAME} artifactory:true
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_wrapper_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }

                // deploy release version
                stage('Deploy Core Release') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "release-core-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:release tag:${env.TAG_NAME} artifactory:true
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_core_podspec environment:release tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy Ads Release') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "release-ads-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:release tag:${env.TAG_NAME} artifactory:true
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_ads_podspec environment:release tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
                stage('Deploy wrapper Release') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "release-wrapper-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_wrapper_framework environment:release tag:${env.TAG_NAME} artifactory:true
                        """

                        withAWS(role:'ci-eu-west-1-macos-jenkins-ci', roleAccount:'556593845588')  {
                            script {
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }

                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_wrapper_podspec environment:release tag:${env.TAG_NAME}
                            """
                        }
                    }
                }

            }
        }
    }
}
