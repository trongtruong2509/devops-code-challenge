# ECS Deployment Jenkins Pipelines

This directory contains Jenkins pipeline files for deploying and updating ECS task definitions and services for the Feather application.

## Files

- `Jenkinsfile.frontend`: Pipeline for deploying the frontend service
- `Jenkinsfile.backend`: Pipeline for deploying the backend service
- `frontend-task-definition.json`: Template task definition for the frontend service
- `backend-task-definition.json`: Template task definition for the backend service
- `register-task-definitions.sh`: Script for manually registering task definitions

## Setting Up in Jenkins

1. Create a new Pipeline job in Jenkins
2. Configure the job to use Pipeline script from SCM
3. Specify your Git repository and credentials
4. Set the Script Path to either:
   - `devops-code-challenge/task-definitions/Jenkinsfile.backend` for the backend service
   - `devops-code-challenge/task-definitions/Jenkinsfile.frontend` for the frontend service

## Required Parameters

When running the jobs, you'll need to provide the following parameters:

### Backend Pipeline Parameters

- `AWS_REGION`: AWS Region for deployment (default: us-east-1)
- `AWS_ACCOUNT_ID`: Your AWS Account ID (required)
- `IMAGE_TAG`: Docker image tag to deploy (default: latest)
- `ECS_CLUSTER`: ECS Cluster name (default: feather)
- `SERVICE_NAME`: ECS Service name (default: feather-backend-service)
- `FRONTEND_ALB_DNS_NAME`: DNS name of the frontend ALB for CORS configuration (required)
- `DESIRED_COUNT`: Desired task count (default: 1)

### Frontend Pipeline Parameters

- `AWS_REGION`: AWS Region for deployment (default: us-east-1)
- `AWS_ACCOUNT_ID`: Your AWS Account ID (required)
- `IMAGE_TAG`: Docker image tag to deploy (default: latest)
- `ECS_CLUSTER`: ECS Cluster name (default: feather)
- `SERVICE_NAME`: ECS Service name (default: feather-frontend-service)
- `BACKEND_URL`: Backend URL for frontend service (default: http://feather-backend.feather.internal:8080)
- `DESIRED_COUNT`: Desired task count (default: 1)

## Pipeline Execution Order

For a complete deployment:

1. Run the backend pipeline first
2. After successful backend deployment, run the frontend pipeline

## AWS Credentials

The pipeline assumes that AWS credentials are available to Jenkins. You can:

1. Use Jenkins credentials plugin with AWS credentials
2. Use EC2 instance role if Jenkins is running on EC2
3. Configure AWS credentials in Jenkins environment

## Prerequisites

Before running these pipelines, ensure:

1. AWS infrastructure is deployed using Terraform
2. ECR repositories exist with the required Docker images
3. VPC, subnets, security groups, and load balancer are configured
4. AWS CLI is installed on the Jenkins server

## Manual Deployment

If you prefer to deploy manually without Jenkins, you can use the `register-task-definitions.sh` script:

```bash
cd /d/repos/mithilesh/feather/devops-code-challenge/task-definitions

# Set required environment variables
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=your_account_id
export FRONTEND_ALB_DNS_NAME=your_alb_dns_name

# Run the script
./register-task-definitions.sh
```
