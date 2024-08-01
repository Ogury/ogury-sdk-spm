  
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
                stage('Deploy Core Internal dev') {
                    when {
                        beforeAgent true
                        tag "internal-core-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:prod tag:${env.TAG_NAME}
                        """
                    }
                }
                stage('Deploy Core Internal release') {
                    when {
                        beforeAgent true
                        tag "internal-core-release-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_core_framework environment:prod tag:${env.TAG_NAME} release:true
                        """
                    }
                }
                stage('Deploy Ads Internal dev') {
                    when {
                        beforeAgent true
                        tag "internal-ads-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:prod tag:${env.TAG_NAME}
                        """
                    }
                }
                stage('Deploy Ads Internal release') {
                    when {
                        beforeAgent true
                        tag "internal-ads-release-*"
                    }
                    steps {

                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_ads_framework environment:prod tag:${env.TAG_NAME} release:true
                        """
                    }
                }

                stage('Deploy Beta') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "beta-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_artefact environment:beta tag:${env.TAG_NAME}
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
                                bundle exec fastlane deploy_podspec environment:beta tag:${env.TAG_NAME}
                            """
                        }
                    }
                }

                stage('Deploy Release') {
                    environment {
                        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
                    }
                    when {
                        beforeAgent true
                        tag "release-*"
                    }
                    steps {
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_artefact environment:release tag:${env.TAG_NAME}
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
                                bundle exec fastlane deploy_podspec environment:release tag:${env.TAG_NAME}
                            """
                        }
                    }
                }
            }
        }
    }
}
