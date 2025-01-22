  
@Library('ogury-jenkins-lib@v7.5.1') _

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
                anyOf {
                    not { changeRequest() }
                    buildingTag()
                }
                expression {
                    // Skip this step if TAG_NAME contains 'internal-testApp'
                    !env.TAG_NAME?.contains('internal-testApp')
                }
            }
            steps {
                script {
                    // Default to false
                    def isArtifactory = false
                    def targetThreshold = "all"
                    def killModeEnabled = false
                    
                    // Check if a tag exists and contains '-art'
                    if (env.GIT_TAG && (env.GIT_TAG.contains('-art') || env.GIT_TAG.contains('release-') )) {
                        isArtifactory = true
                    }

                    if (env.GIT_TAG && env.GIT_TAG.contains('-core-')) {
                        targetThreshold = "core"
                    }
                    if (env.GIT_TAG && env.GIT_TAG.contains('-ads-')) {
                        targetThreshold = "ads"
                    }
                    if (env.GIT_TAG && env.GIT_TAG.contains('-killModeEnabled')) {
                        killModeEnabled = true
                    }
        
                    // Log the value of isArtifactory for debugging
                    echo "Artifactory is set to: ${isArtifactory}"
                    echo "Target Threshold is set to: ${targetThreshold}"
                    echo "killModeEnabled is set to: ${killModeEnabled}"
        
                    // Run the first shell script (setting up environment)
                    sh """#!/bin/zsh -l
                    source ~/.zshrc
                    rvm --default use 2.7.7
                    """
        
                    // Run the Fastlane build with artifactory set based on the tag
                    sh """#!/bin/zsh -l
                    source ~/.zshrc
                    bundle exec fastlane build environment:'prod' artifactory:${isArtifactory} targetThreshold:${targetThreshold} killModeEnabled:${killModeEnabled}
                    """
                }
            }
        }

        stage('Test-Dev') {
            when {
                beforeAgent true
                changeRequest()
                not {
                    branch 'master'
                }
                expression {
                    // Skip this step if TAG_NAME contains 'internal-testApp'
                    !env.TAG_NAME?.contains('internal-testApp')
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
                expression {
                    // Skip this step if TAG_NAME contains 'internal-testApp'
                    !env.TAG_NAME?.contains('internal-testApp')
                }
            }
            steps {
                sh """#!/bin/zsh -l
                    mkdir -p jenkins
                    bundle exec fastlane test environment:release
                """
            }
        }

        // Deployments
        stage('Deployments') {
            when {
                beforeAgent true
                buildingTag()
                not { changeRequest() }
            }
            steps {
                script {
                    // Parse TAG_NAME to determine framework, environment, and extra conditions
                    def elements = "${env.TAG_NAME}".split("-")
                    if (elements.size() < 3) {
                        error "Invalid TAG_NAME format: Expected at least two elements, got ${elements.size()}"
                    }

                    def isArtifactory = elements.contains("art")
                    def killModeEnabled = elements.contains("killModeEnabled")

                    // environment : internal - beta - release
                    def envType = ""
                    switch (elements[0]) {
                        case "internal":
                            envType = "prod"
                            break
                        case "beta":
                            envType = "beta"
                            break
                        case "release":
                            envType = "release"
                            // Ensure that release mode always has this setting to false
                            killModeEnabled = false
                            // always use external dependencies when compiling for prod
                            isArtifactory = true
                            break
                        default:
                            error "Unknown environment type: ${elements[0]}"
                    }

                    // framework : ads - core - wrapper
                    def framework = ""
                    switch (elements[1]) {
                        case "core":
                            framework = "core"
                            break
                        case "ads":
                            framework = "ads"
                            break
                        case "wrapper":
                            framework = "wrapper"
                            break
                        default:
                            error "Unknown framework type: ${elements[1]}"
                    }

                    def isBetaOrRelease = (envType == "beta" || envType == "release")
                    if (isBetaOrRelease) {
                        withEnv(['GIT_SSH_COMMAND=ssh -o StrictHostKeyChecking=no']) {
                            echo "Environment variables for beta/release set."
                        }
                    }
        
                    echo "Deploying ${framework} in ${envType} mode, artifactory: ${isArtifactory}, killModeEnabled: ${killModeEnabled}"

                    // Main deployment logic
                    sh """#!/bin/zsh -l
                        bundle exec fastlane deploy_${framework}_framework environment:${envType} tag:${env.TAG_NAME} artifactory:${isArtifactory} killModeEnabled:${killModeEnabled}
                    """
        
                    // Handle additional steps for beta/release
                    if (isBetaOrRelease) {
                        withAWS(role: 'ci-eu-west-1-macos-jenkins-ci', roleAccount: '556593845588') {
                            script {
                                echo "Uploading artifacts to S3..."
                                s3Utils.uploadDir(
                                    localDir: 'jenkins/output/amazon',
                                    bucket: 'ogury-sdk-binaries',
                                    prefix: ''
                                )
                            }
                        }
        
                        sshagent(['Ogy-JenkinsAuth']) {
                            sh """#!/bin/zsh -l
                                bundle exec fastlane deploy_${framework}_podspec environment:${envType} tag:${env.TAG_NAME} artifactory:${isArtifactory}
                            """
                        }
                    }
                }
            }
        }
    }
}
