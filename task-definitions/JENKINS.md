# ECS Deployment Jenkins Pipelines

This directory contains Jenkins pipeline files for deploying and updating ECS task definitions and services for the Feather application.

## Files

- `Jenkinsfile.frontend`: Pipeline for deploying the frontend service
- `Jenkinsfile.backend`: Pipeline for deploying the backend service
- `frontend-task-definition.json`: Template task definition for the frontend service
- `backend-task-definition.json`: Template task definition for the backend service
- `register-task-definitions.sh`: Script for manually registering task definitions
- `jenkins-job-dsl.groovy`: Job DSL script to automatically create Jenkins pipeline jobs

## Jenkins Pipeline Setup

### 1. Create Jenkins Pipeline Jobs

You have two options for creating the Jenkins pipeline jobs:

#### Option 1: Manual Creation

In your Jenkins instance, create two pipeline jobs:

1. **Frontend Deployment Pipeline**
   - Name: `feather-frontend-deployment`
   - Pipeline script from SCM
   - SCM: Git
   - Repository URL: `<your-git-repo-url>`
   - Script Path: `devops-code-challenge/task-definitions/Jenkinsfile.frontend`

2. **Backend Deployment Pipeline**
   - Name: `feather-backend-deployment`
   - Pipeline script from SCM
   - SCM: Git
   - Repository URL: `<your-git-repo-url>`
   - Script Path: `devops-code-challenge/task-definitions/Jenkinsfile.backend`

#### Option 2: Using Job DSL (Recommended)

1. Install the "Job DSL" plugin in Jenkins
2. Create a "Seed Job":
   - Create a new freestyle project named "feather-seed-job"
   - Add a build step "Process Job DSLs"
   - Select "Use the provided DSL script"
   - Copy the contents of `jenkins-job-dsl.groovy` into the script box
   - Or select "Look on filesystem" and specify the path to the file
   - Save and run the job

This will automatically create three jobs:
- `feather-frontend-deployment`: For deploying the frontend service
- `feather-backend-deployment`: For deploying the backend service
- `feather-full-deployment`: A job that triggers both deployments in sequence

### 2. Required Parameters

Both pipelines require parameters that you'll need to provide when running the job:

#### Frontend Pipeline Parameters

- `AWS_REGION`: AWS Region for deployment (default: us-east-1)
- `AWS_ACCOUNT_ID`: Your AWS Account ID
- `IMAGE_TAG`: Docker image tag to deploy (default: latest)
- `ECS_CLUSTER`: ECS Cluster name (default: feather)
- `SERVICE_NAME`: ECS Service name (default: feather-frontend-service)
- `BACKEND_URL`: Backend URL for frontend service (default: http://feather-backend.feather.internal:8080)
- `DESIRED_COUNT`: Desired task count (default: 1)

#### Backend Pipeline Parameters

- `AWS_REGION`: AWS Region for deployment (default: us-east-1)
- `AWS_ACCOUNT_ID`: Your AWS Account ID
- `IMAGE_TAG`: Docker image tag to deploy (default: latest)
- `ECS_CLUSTER`: ECS Cluster name (default: feather)
- `SERVICE_NAME`: ECS Service name (default: feather-backend-service)
- `FRONTEND_ALB_DNS_NAME`: DNS name of the frontend ALB for CORS configuration
- `DESIRED_COUNT`: Desired task count (default: 1)

### 3. Jenkins Credentials

The pipelines assume that AWS credentials are configured in Jenkins. You can use:

1. Jenkins Credentials Plugin with AWS credentials
2. AWS EC2 Instance Role (if Jenkins is running on EC2)
3. Environment variables set in the Jenkins configuration

### 4. Pipeline Execution Order

For a complete deployment:

1. Run the backend pipeline first
2. After successful backend deployment, run the frontend pipeline

Alternatively, use the `feather-full-deployment` job created by the Job DSL script to run both deployments in sequence with a single click.

### 5. Prerequisites

Before running these pipelines, ensure:

1. ECS cluster is created via Terraform
2. ECR repositories exist and contain the Docker images
3. VPC, subnets, and security groups are properly configured
4. Service discovery namespace and service (for backend) are created

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

Then use the AWS CLI to create or update your services.

## Command Line Deployment

A CLI script is provided to trigger Jenkins jobs from the command line. This is useful for integrating with other scripts or for testing:

```bash
# Set up Jenkins credentials
export JENKINS_URL="http://jenkins.example.com:8080"
export JENKINS_USER="your_username"
export JENKINS_API_TOKEN="your_api_token"

# Deploy both services
./trigger-jenkins-pipeline.sh full \
  --account-id 123456789012 \
  --dns-name myapp-lb.us-east-1.elb.amazonaws.com \
  --backend-tag v1.0.0 \
  --frontend-tag v1.0.0

# Deploy only the backend service
./trigger-jenkins-pipeline.sh backend \
  --account-id 123456789012 \
  --dns-name myapp-lb.us-east-1.elb.amazonaws.com \
  --backend-tag v1.0.0

# Deploy only the frontend service
./trigger-jenkins-pipeline.sh frontend \
  --account-id 123456789012 \
  --frontend-tag v1.0.0
```

Run `./trigger-jenkins-pipeline.sh --help` for more information on available options.
