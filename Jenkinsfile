@Library('my-shared-library') _

pipeline {
    agent any

    tools {
        nodejs 'node20' 
    }

    stages {
        stage('Skip bot commits') {
            steps {
                script {
                    def author = sh(
                        script: "git log -1 --pretty=%an",
                        returnStdout: true
                    ).trim()

                    if (author == "Jenkins CI") {
                        currentBuild.result = 'NOT_BUILT'
                        error("Skipping build (commit from Jenkins)")
                    }
                }
            }
        }

        stage('Test') {
            steps {
                testNpm(directory: 'app')
            }
        }

        stage('Version Bump') {
            when {
                branch 'main'
            }
            steps {
                script {
                    env.APP_VERSION = versionNpmBump(
                        directory: 'app',
                        type: 'patch'
                    )
                }
                echo "Version: ${env.APP_VERSION}"
            }
        }

        stage('Build & Push Image') {
            when {
                branch 'main'
            }
            steps {
                buildAndPushDocker(
                    repo: 'adribalbvena/node-app',
                    tag: env.APP_VERSION,
                )
            }
        }

        stage('Deploy to EC2') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def remoteIp = "3.77.193.229" 
                    
                    sshagent(['aws-ec2-key']) {
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ec2-user@${remoteIp}:/home/ec2-user/docker-compose.yaml"

                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${remoteIp} "
                                export APP_VERSION=${env.APP_VERSION}                                
                                /usr/local/bin/docker-compose up -d
                                docker image prune -f
                            "
                        """
                    }
                }
            }
        }

        stage('Git Commit & Push') {
            when {
                branch 'main'
            }
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