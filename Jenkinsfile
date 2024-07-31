  
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
    }
}
