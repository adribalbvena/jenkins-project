@Library('my-shared-library') _

pipeline {
    agent any

    tools {
        nodejs 'node20' 
    }

    environment {
        DOCKER_REPO = 'adribalbvena/node-app'
        GITHUB_REPO = 'jenkins-project'
        DOCKER_HUB_CREDS = 'docker-hub-creds'
        GITHUB_CREDS = 'github-creds'
        VERSION = ''
    }

    stages {
        stage('Test & Version') {
            steps {
                script {
                    env.APP_VERSION = testAndIncrementVersion(directory: 'app', type: 'patch')
                }
                echo "Version: ${env.APP_VERSION}"
            }
        }
        

        stage('Build & Push Image') {
            steps {
                buildAndPushDocker(
                    repo: env.DOCKER_REPO,
                    tag: env.APP_VERSION,
                    credsId: env.DOCKER_HUB_CREDS
                )
            }
        }

        stage('Git Commit & Push') {
            steps {
                pushToGithub(
                    credsId: env.GITHUB_CREDS,
                    repoName: env.GITHUB_REPO,
                    file: 'app/package.json',
                    message: "chore: Bump version to ${env.APP_VERSION}"
                )
            }
        }
    }
}