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

        stage('Deploy to EC2') {
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