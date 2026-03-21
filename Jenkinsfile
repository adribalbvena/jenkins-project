pipeline {
    agent any

    tools {
        nodejs 'node20' 
    }

    environment {
        DOCKER_REPO = 'adribalbvena/node-app'
        DOCKER_HUB_CREDS = 'docker-hub-creds'
        GIT_SERVER_CREDS = 'github-creds'
        VERSION = ''
    }

    stages {
        stage('Test & Version') {
            steps {
                dir('app') {
                    sh 'npm install'
                    sh 'npm test'                 
                    sh 'npm version patch --no-git-tag-version'
                    
                    script {
                        env.APP_VERSION = sh(script: "node -p \"require('./package.json').version\"", returnStdout: true).trim()
                    }
                }
                echo "Version: ${env.APP_VERSION}"
            }
        }

        stage('Build & Push Image') {
            steps {
                sh "docker build -t ${DOCKER_REPO}:${env.APP_VERSION} ."

                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo \$PASS | docker login -u \$USER --password-stdin"    
                    sh "docker push ${DOCKER_REPO}:${env.APP_VERSION}"
                    sh "docker logout"
                }
            }
        }

        stage('Git Commit & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${GIT_SERVER_CREDS}", passwordVariable: 'GIT_TOKEN', usernameVariable: 'GIT_USER')]) {
                    sh 'git config user.email "jenkins-bot@example.com"'
                    sh 'git config user.name "Jenkins CI"'
            
                    sh 'git add app/package.json'
                    sh "git commit -m 'chore: bump version to ${env.APP_VERSION}'"

                    sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/${GIT_USER}/jenkins-project.git HEAD:main"
                }
            }
        }
    }
}