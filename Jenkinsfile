@Library('my-shared-library') _

pipeline {
    agent any

    tools {
        nodejs 'node20' 
    }

    environment {
        VERSION = ''
    }

    stages {
        stage('Test & Version') {
            steps {
                script {
                    env.APP_VERSION = testAndIncrementNpmVersion(directory: 'app', type: 'patch')
                }
                echo "Version: ${env.APP_VERSION}"
            }
        }
        

        stage('Build & Push Image') {
            steps {
                buildAndPushDocker(
                    repo: 'adribalbvena/node-app',
                    tag: env.APP_VERSION,
                )
            }
        }

        stage('Git Commit & Push') {
            steps {
                pushToGithub(
                    repoName: 'jenkins-project',
                    file: 'app/package.json',
                    message: "chore: Bump version to ${env.APP_VERSION}"
                )
            }
        }
    }
}