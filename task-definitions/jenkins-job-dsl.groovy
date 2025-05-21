#!/usr/bin/env groovy

// This script defines Jenkins pipeline jobs for ECS deployment
// To use this script, you need to have the Jenkins Job DSL plugin installed
// Run this script in the Jenkins Script Console or use it with a seed job

// Define repository URL - replace with your actual Git repo URL
def gitRepoUrl = 'https://github.com/yourusername/feather.git'
def gitBranch = 'main'

// Frontend Deployment Pipeline
pipelineJob('feather-frontend-deployment') {
    description('Pipeline to deploy the Feather frontend service to ECS')
    
    parameters {
        stringParam('AWS_REGION', 'us-east-1', 'AWS Region for deployment')
        stringParam('AWS_ACCOUNT_ID', '', 'AWS Account ID')
        stringParam('IMAGE_TAG', 'latest', 'Docker image tag to deploy')
        stringParam('ECS_CLUSTER', 'feather', 'ECS Cluster name')
        stringParam('SERVICE_NAME', 'feather-frontend-service', 'ECS Service name')
        stringParam('BACKEND_URL', 'http://feather-backend.feather.internal:8080', 'Backend URL for frontend service')
        stringParam('DESIRED_COUNT', '1', 'Desired task count')
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url(gitRepoUrl)
                    }
                    branch(gitBranch)
                    scriptPath('devops-code-challenge/task-definitions/Jenkinsfile.frontend')
                }
            }
        }
    }
}

// Backend Deployment Pipeline
pipelineJob('feather-backend-deployment') {
    description('Pipeline to deploy the Feather backend service to ECS')
    
    parameters {
        stringParam('AWS_REGION', 'us-east-1', 'AWS Region for deployment')
        stringParam('AWS_ACCOUNT_ID', '', 'AWS Account ID')
        stringParam('IMAGE_TAG', 'latest', 'Docker image tag to deploy')
        stringParam('ECS_CLUSTER', 'feather', 'ECS Cluster name')
        stringParam('SERVICE_NAME', 'feather-backend-service', 'ECS Service name')
        stringParam('FRONTEND_ALB_DNS_NAME', '', 'DNS name of the frontend ALB for CORS configuration')
        stringParam('DESIRED_COUNT', '1', 'Desired task count')
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url(gitRepoUrl)
                    }
                    branch(gitBranch)
                    scriptPath('devops-code-challenge/task-definitions/Jenkinsfile.backend')
                }
            }
        }
    }
}

// Combined deployment that runs backend first, then frontend
job('feather-full-deployment') {
    description('Pipeline to deploy both Feather backend and frontend services to ECS')
    
    parameters {
        stringParam('AWS_REGION', 'us-east-1', 'AWS Region for deployment')
        stringParam('AWS_ACCOUNT_ID', '', 'AWS Account ID')
        stringParam('BACKEND_IMAGE_TAG', 'latest', 'Backend Docker image tag to deploy')
        stringParam('FRONTEND_IMAGE_TAG', 'latest', 'Frontend Docker image tag to deploy')
        stringParam('ECS_CLUSTER', 'feather', 'ECS Cluster name')
        stringParam('BACKEND_SERVICE_NAME', 'feather-backend-service', 'Backend ECS Service name')
        stringParam('FRONTEND_SERVICE_NAME', 'feather-frontend-service', 'Frontend ECS Service name')
        stringParam('FRONTEND_ALB_DNS_NAME', '', 'DNS name of the frontend ALB for CORS configuration')
        stringParam('DESIRED_COUNT', '1', 'Desired task count')
    }
    
    steps {
        // Run backend deployment
        downstreamParameterized {
            trigger('feather-backend-deployment') {
                parameters {
                    predefinedProp('AWS_REGION', '${AWS_REGION}')
                    predefinedProp('AWS_ACCOUNT_ID', '${AWS_ACCOUNT_ID}')
                    predefinedProp('IMAGE_TAG', '${BACKEND_IMAGE_TAG}')
                    predefinedProp('ECS_CLUSTER', '${ECS_CLUSTER}')
                    predefinedProp('SERVICE_NAME', '${BACKEND_SERVICE_NAME}')
                    predefinedProp('FRONTEND_ALB_DNS_NAME', '${FRONTEND_ALB_DNS_NAME}')
                    predefinedProp('DESIRED_COUNT', '${DESIRED_COUNT}')
                }
                block {
                    buildStepFailure('FAILURE')
                    failure('FAILURE')
                    unstable('UNSTABLE')
                }
            }
        }
        
        // Run frontend deployment
        downstreamParameterized {
            trigger('feather-frontend-deployment') {
                parameters {
                    predefinedProp('AWS_REGION', '${AWS_REGION}')
                    predefinedProp('AWS_ACCOUNT_ID', '${AWS_ACCOUNT_ID}')
                    predefinedProp('IMAGE_TAG', '${FRONTEND_IMAGE_TAG}')
                    predefinedProp('ECS_CLUSTER', '${ECS_CLUSTER}')
                    predefinedProp('SERVICE_NAME', '${FRONTEND_SERVICE_NAME}')
                    predefinedProp('BACKEND_URL', 'http://feather-backend.feather.internal:8080')
                    predefinedProp('DESIRED_COUNT', '${DESIRED_COUNT}')
                }
            }
        }
    }
}
