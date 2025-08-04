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
                    echo ">> Detected Git tag: '${env.GIT_TAG}'"
        
                    if (env.GIT_TAG.endsWith("-dry")) {
                        echo "Detected dry run tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "dry"
        
                    } else if (env.GIT_TAG == "") {
                        echo "No Git tag found. Running in default mode (not a release)."
                        env.RUN_MODE = "default"
        
                    // ✅ First check for release (more specific)
                    } else if (env.GIT_TAG ==~ /^sdk-release-\d+\.\d+\.\d+(-[\w\.]+)?$/) {
                        echo "Detected public release tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "release"
                    
                        if (!fileExists(env.CHANGELOG_FILE)) {
                            error "Changelog file '${env.CHANGELOG_FILE}' is required for release builds but was not found."
                        }
                    
                    } else if (env.GIT_TAG ==~ /^internal-\d+\.\d+\.\d+(-[\w\.]+)?$/) {
                        echo "Detected internal release tag: ${env.GIT_TAG}"
                        env.RUN_MODE = "internal"
        
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


        stage('Build Swift Package') {
            steps {
                sh 'swift package resolve'
                sh '''
                echo "Patching local Swift package path in Xcode project..."
                set -euo pipefail
            
                echo "Patching local Swift package path in Xcode project..."
            
                PBXPROJ="OgurySpmTestApp.xcodeproj/project.pbxproj"
                # Use sed to patch the repositoryURL in ogury-sdk-spm package block
                LOCAL_PATH="$(pwd)"
            
                # Escape the path for sed
                ESCAPED_PATH=$(printf '%s\n' "$LOCAL_PATH" | sed 's/[\\/&]/\\\\&/g')
        
                sed -E "/XCLocalSwiftPackageReference.*ogury-sdk-spm/,/}/ {
                  s|(relativePath = ).*;|\\1\\\"$ESCAPED_PATH\\\";|
                }" "$PBXPROJ" > "$PBXPROJ.patched"
                
                mv "$PBXPROJ.patched" "$PBXPROJ"

                echo "✅ Patched relativePath to local path: $LOCAL_PATH"
                grep -A 5 -B 2 'ogury-sdk-spm' "$PBXPROJ"

                echo "Building test app with patched local package..."
                xcodebuild build \
                  -project OgurySpmTestApp.xcodeproj \
                  -scheme OgurySpmTestApp \
                  -destination "generic/platform=iOS Simulator"
                '''
            }
        }

        stage('Create Git Tag & Release') {
            when {
                expression { env.RUN_MODE == "release" || env.RUN_MODE == "internal" }
            }
            steps {
                script {
                    def version = env.GIT_TAG.replaceFirst(/^release-/, "")
                    def releaseTag = "v${version}"
                    echo "Creating Git tag: ${releaseTag}"

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
                }
            }
        }
    }
}