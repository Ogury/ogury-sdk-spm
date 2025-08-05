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
                    env.TAG_NAME = env.TAG_NAME?.trim() ?: ""
                    echo ">> Detected Git tag: '${env.TAG_NAME}'"
        
                    if (env.TAG_NAME.endsWith("-dry")) {
                        echo "Detected dry run tag: ${env.TAG_NAME}"
                        env.RUN_MODE = "dry"
        
                    } else if (env.TAG_NAME == "") {
                        echo "No Git tag found. Running in default mode (not a release)."
                        env.RUN_MODE = "default"
        
                    // ✅ First check for release (more specific)
                    } else if (env.TAG_NAME ==~ /^sdk-release-\d+\.\d+\.\d+(-[\w\.]+)?$/) {
                        echo "Detected public release tag: ${env.TAG_NAME}"
                        env.RUN_MODE = "release"
                    
                        if (!fileExists(env.CHANGELOG_FILE)) {
                            error "Changelog file '${env.CHANGELOG_FILE}' is required for release builds but was not found."
                        }
                    
                    } else if (env.TAG_NAME ==~ /^internal-\d+\.\d+\.\d+(-[\w\.]+)?$/) {
                        echo "Detected internal release tag: ${env.TAG_NAME}"
                        env.RUN_MODE = "internal"
        
                    } else {
                        echo "Tag '${env.TAG_NAME}' doesn't match any expected pattern. Proceeding in default mode."
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
                expression { env.RUN_MODE == "release"}
            }
            steps {
                script {
                    def version = env.TAG_NAME
                        .replaceFirst(/^sdk-release-/, "")
                        .replaceFirst(/^internal-/, "")
                    def releaseTag = "${version}"
                    echo "Preparing Git tag: ${releaseTag}"
        
                    // Check if the tag already exists
                    def tagExists = sh(
                        script: "git tag -l ${releaseTag}",
                        returnStdout: true
                    ).trim()
        
                    if (tagExists) {
                        echo "Git tag ${releaseTag} already exists. Skipping tag creation."
                    } else {
                        echo "Creating git tag ${releaseTag}"
        
                        // Use HTTPS with token to push tag
                        def gitUrl = "https://github.com/Ogury/ogury-sdk-spm.git"
                        echo "🔗 Git remote URL: ${gitUrl.replace(env.GIT_TOKEN, '****')}"
        
                        sh """
                            git config user.email "sdk.developers@ogury.co"
                            git config user.name "weareogury"
                            git tag -a ${releaseTag} -m "Release ${releaseTag}"
        
                            # Push using token-authenticated HTTPS
                            git remote set-url origin ${gitUrl}
                            git push origin ${releaseTag}

                            curl -s -X POST https://api.github.com/repos/ogury/ogury-sdk-spm/releases \\
                              -H "Authorization: token ${env.GIT_TOKEN}" \\
                              -H "Content-Type: application/json" \\
                              -d '{
                                "tag_name": "${releaseTag}",
                                "name": "Release ${releaseTag}",
                                "body": "Automatically created by Jenkins",
                                "draft": false,
                                "prerelease": true
                              }'
                        """
                    }
                }
            }
        }
    }
}