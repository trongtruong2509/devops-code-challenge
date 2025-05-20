pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'  // Change to your AWS region
        AWS_CREDENTIALS = 'aws-credentials' // Jenkins credentials ID for AWS
        AWS_ACCOUNT_ID = credentials('aws-account-id')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy Infrastructure') {
            steps {
                echo 'Setting up infrastructure if needed...'
                // Add steps to setup infrastructure with Terraform if needed
            }
        }
        
        stage('Build and Push Images') {
            parallel {
                stage('Frontend') {
                    steps {
                        build job: 'lightfeather-frontend-pipeline', 
                              parameters: [
                                  string(name: 'AWS_REGION', value: "${env.AWS_REGION}"),
                                  string(name: 'AWS_ACCOUNT_ID', value: "${env.AWS_ACCOUNT_ID}"),
                                  string(name: 'AWS_CREDENTIALS_ID', value: "${env.AWS_CREDENTIALS}")
                              ]
                    }
                }
                stage('Backend') {
                    steps {
                        build job: 'lightfeather-backend-pipeline',
                              parameters: [
                                  string(name: 'AWS_REGION', value: "${env.AWS_REGION}"),
                                  string(name: 'AWS_ACCOUNT_ID', value: "${env.AWS_ACCOUNT_ID}"),
                                  string(name: 'AWS_CREDENTIALS_ID', value: "${env.AWS_CREDENTIALS}")
                              ]
                    }
                }
            }
        }
        
        stage('Deploy to ECS/EKS') {
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS}", region: "${AWS_REGION}") {
                    echo 'Deploying to ECS or EKS...'
                    // Add your deployment steps here
                    // For example: Update ECS service or apply Kubernetes manifests
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Deployment completed successfully'
        }
        failure {
            echo 'Deployment failed'
        }
    }
}
