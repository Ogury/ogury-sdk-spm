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
                    } else if (env.GIT_TAG ==~ /^internal-\d+\.\d+\.\d+(-[\w\.]+)?$/) {
                        echo "Detected internal release tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "internal"
                    } else if (env.GIT_TAG ==~ /^sdk-release-\d+\.\d+\.\d+$/) {
                        echo "Detected public release tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "release"
        
                        if (!fileExists(env.CHANGELOG_FILE)) {
                            error "Changelog file '${env.CHANGELOG_FILE}' is required for release builds but was not found."
                        }
                    } else {
                        echo "Tag '${env.GIT_TAG}' doesn't match any expected pattern. Proceeding in default mode."
                        env.RUN_MODE = "default"
                    }
                }
            }
        }
        
        stage('Run Update Script') {
            steps {
                script {
                    def updateCommand = "ruby ${env.UPDATE_SCRIPT}"

                    if (env.RUN_MODE == "release") {
                        updateCommand += " --tag"
                    } else {
                        updateCommand += " --internal"
                    }

                    echo "Running update script with command: ${updateCommand}"
                    sh updateCommand
                }
            }
        }

        stage('Build') {
            when {
                anyOf {
                    expression { env.RUN_MODE == "release" }
                    expression { env.RUN_MODE == "internal" }
                }
            }
            steps {
                echo "Build SDK version ${env.GIT_VERSION} for mode: ${env.RUN_MODE}"
                sh "./scripts/build_package.sh"
            }
        }

        stage('Create Git Tag & Release') {
            when {
                expression { env.RUN_MODE == "release" }
            }
            steps {
                script {
                    def releaseTag = "v${env.GIT_VERSION}"

                    // Check if the tag already exists (e.g., created by Ruby script)
                    def tagExists = sh(
                        script: "git tag -l ${releaseTag}",
                        returnStdout: true
                    ).trim()

                    if (tagExists) {
                        echo "Git tag ${releaseTag} already exists. Skipping tag creation."
                    } else {
                        echo "Creating git tag ${releaseTag}"
                        sh """
                            git config user.email "ci@yourdomain.com"
                            git config user.name "CI Bot"
                            git tag -a ${releaseTag} -m "Release ${releaseTag}"
                            git push origin ${releaseTag}
                        """
                    }

                    // Optional: generate release via GitHub CLI if not done in Ruby
                    // sh "gh release create ${releaseTag} --title ${releaseTag} --notes-file ${CHANGELOG_FILE}"
                }
            }
        }
    }
}