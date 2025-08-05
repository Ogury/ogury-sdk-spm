  
@Library('ogury-jenkins-lib@v7.5.1') _

pipeline {
    agent {
        label 'macM2-worker'
    }

    environment {
        GIT_TOKEN = credentials('GIT_TOKEN')
        GIT_USERNAME = "weareogury"
        LC_ALL = 'en_US.UTF-8'
        PATH = "$HOME/.rvm/bin:$PATH" // ensure RVM is found
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
                    echo "TAG_NAME is: ${env.TAG_NAME}"

                    // Default to false
                    def isArtifactory = false
                    def killModeEnabled = false
                    def targetThreshold = "all"
                    
                    // Check if a tag exists and contains '-art'
                    if (env.TAG_NAME && (env.TAG_NAME.contains('-art') || env.TAG_NAME.contains('release-') )) {
                        isArtifactory = true
                    }

                    if (env.TAG_NAME && env.TAG_NAME.contains('-core-')) {
                        targetThreshold = "core"
                    }
                    if (env.TAG_NAME && env.TAG_NAME.contains('-ads-')) {
                        targetThreshold = "ads"
                    }
                    if (env.TAG_NAME && env.TAG_NAME.contains('wrapper')) {
                        targetThreshold = "sdk"
                    }
                    if (env.TAG_NAME && env.TAG_NAME.contains('-killModeEnabled')) {
                        killModeEnabled = true
                    }
        
                    // Log the value of isArtifactory for debugging
                    echo "Artifactory is set to: ${isArtifactory}"
                    echo "Target Threshold is set to: ${targetThreshold}"
                    echo "killModeEnabled is set to: ${killModeEnabled}"
        
                    // Run the Fastlane build with artifactory set based on the tag
                    sh """#!/bin/zsh -l
                        source ~/.zshrc
                        source $HOME/.rvm/scripts/rvm
                        rvm use 3.3.1 --default
                        ruby -v
                        gem uninstall bundler
                        gem install bundler
                        bundle install
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
                expression {
                    // Skip this step if TAG_NAME contains 'internal-testApp'
                    !env.TAG_NAME?.contains('internal-testApp')
                }
            }
            steps {
                withAWS(role: 'ci-eu-west-1-macos-jenkins-ci', roleAccount: '556593845588') {
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

                        // framework : ads (+ omid) - core - wrapper
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

                    def targetThreshold = "all"
                    if (env.TAG_NAME && env.TAG_NAME.contains('-core-')) {
                        targetThreshold = "core"
                    }
                    if (env.TAG_NAME && env.TAG_NAME.contains('-ads-')) {
                        targetThreshold = "ads"
                    }
                    if (env.TAG_NAME && env.TAG_NAME.contains('wrapper')) {
                        targetThreshold = "sdk"
                    }
                    if (env.TAG_NAME && env.TAG_NAME.contains('-killModeEnabled')) {
                        killModeEnabled = true
                    }

                        def isBetaOrRelease = (envType == "beta" || envType == "release")
                        if (isBetaOrRelease) {
                            withEnv(['GIT_SSH_COMMAND=ssh -o StrictHostKeyChecking=no']) {
                                echo "Environment variables for beta/release set."
                            }
                        }
        
                        echo "Deploying ${framework} in ${envType} mode, artifactory: ${isArtifactory}, targetThreshold: ${targetThreshold}, killModeEnabled: ${killModeEnabled}"

                        // Main deployment logic
                        sh """#!/bin/zsh -l
                            bundle exec fastlane deploy_${framework}_framework environment:${envType} tag:${env.TAG_NAME} artifactory:${isArtifactory} targetThreshold:${targetThreshold} killModeEnabled:${killModeEnabled}
                        """
        
                        // Handle additional steps for beta/release
                        if (isBetaOrRelease) {
                            sshagent(['Ogy-JenkinsAuth']) {
                                sh """#!/bin/zsh -l
                                    bundle exec fastlane deploy_${framework}_podspec environment:${envType} tag:${env.TAG_NAME} artifactory:${isArtifactory} targetThreshold:${targetThreshold}
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy Ads Test App') {
            when {
                beforeAgent true
                buildingTag()
                expression {
                    env.TAG_NAME?.contains('internal-testApp@')
                }
            }
            steps {
                script {
                    // Extract app selector from TAG_NAME like "internal-testApp@ogury-1.0.0"
                    def tagName = env.TAG_NAME ?: ""
                    def match = tagName =~ /testApp@([^-\s]+)/
        
                    if (!match) {
                        error("No app selector found in TAG_NAME: ${tagName}")
                    } else {
                        echo "App selector: ${match[1]}"
                    }
        
                    def appSelector = match[0][1]  // e.g., "all, "ogury", "mediation", or "prodTestApp"
                    echo "Found -> ${appSelector}"
        
                    // Additional flags if needed
                    def tagElements = tagName.split("-")
                    def isQa = tagElements.contains("qa")
                    def isArtifactory = tagElements.contains("art")
                    def killModeEnabled = tagElements.contains("killModeEnabled")
        
                    sh """#!/bin/zsh -l
                      bundle exec fastlane generate_test_app \\
                        appSelector:'${appSelector}' \\
                        isQa:${isQa} \\
                        artifactory:${isArtifactory} \\
                        tag:'${tagName}' \\
                        killModeEnabled:${killModeEnabled}
                    """
                }
            }
        }
    }
}
