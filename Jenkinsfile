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
        UPDATE_SCRIPT = "./update_package.rb"
        CHANGELOG_FILE = "CHANGELOG.md"
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    env.GIT_TAG = sh(
                        script: 'git describe --tags --abbrev=0 2>/dev/null || echo ""',
                        returnStdout: true
                    ).trim()

                    if (env.GIT_TAG.endsWith("-dry")) {
                        echo "Detected dry run tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "dry"
                    } else if (env.GIT_TAG == "") {
                        echo "No Git tag found. Running in default mode (not a release)."
                        env.RUN_MODE = "default"
                    } else if (env.GIT_TAG =~ /^release-\d+\.\d+\.\d+$/) {
                        echo "Detected release tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "release"

                        if (!fileExists(env.CHANGELOG_FILE)) {
                            error "Changelog file '${env.CHANGELOG_FILE}' is required for release builds but was not found."
                        }
                    } else {
                        echo "Tag '${env.GIT_TAG}' doesn't match any expected pattern. Proceeding without tagging."
                        env.RUN_MODE = "default"
                    }
                }
            }
        }

        stage('Run Update Script') {
            steps {
                sh "ruby ${env.UPDATE_SCRIPT}"
            }
        }

        stage('Build Swift Package') {
            steps {
                sh 'swift package resolve'
                sh """
                    xcodebuild build -project OgurySpmTestApp.xcodeproj -scheme OgurySpmTestApp -destination 'generic/platform=iOS Simulator'
                """
            }
        }

        stage('Create Git Tag & Release') {
            when {
                expression { env.RUN_MODE == "release" }
            }
            steps {
                script {
                    def version = env.GIT_TAG.replaceFirst(/^release-/, "")
                    def tag = "v${version}"
                    echo "Creating Git tag: ${tag}"

                    sh """
                        git config user.name "${env.GIT_USERNAME}"
                        git config user.email "ci@ogury.co"
                        git add Package.swift
                        git commit -m 'Update Ogury SDK to ${version}' || echo 'No changes to commit'
                        git tag ${tag}
                        git push origin ${tag}
                    """

                    sh "rm -f ${env.CHANGELOG_FILE}"
                    echo "Changelog file deleted after release."
                }
            }
        }
    }
}