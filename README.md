# Feather DevOps Challenge Solution

## Overview
This repository contains a React frontend and an Express backend application deployed on AWS infrastructure using Terraform, Docker, and Jenkins CI/CD pipelines. The solution includes containerized applications running on AWS ECS Fargate with automatic deployment pipelines.

## Infrastructure Components

The deployment includes the following components:

- **AWS VPC** with public and private subnets
- **ECS Fargate Cluster** for running containerized applications
- **ECR Repositories** for storing Docker images
- **Application Load Balancer** for routing traffic to the frontend
- **Service Discovery** for backend service communication
- **Jenkins Server** on EC2 for continuous integration and deployment

## Deployed Application URLs

- **Frontend Application**: [http://feather-alb-12345.us-east-1.elb.amazonaws.com](http://feather-alb-12345.us-east-1.elb.amazonaws.com)
- **Jenkins Server**: [http://ec2-12-34-56-78.compute-1.amazonaws.com:8080](http://ec2-12-34-56-78.compute-1.amazonaws.com:8080)

## Prerequisites

To deploy this infrastructure, you'll need:

1. **AWS Account** with administrative access
2. **AWS CLI** [v2.x+](https://aws.amazon.com/cli/) configured with credentials
3. **Terraform** [v1.0.0+](https://www.terraform.io/downloads)
4. **Git** for repository management
5. **SSH Key Pair** for accessing the Jenkins server
6. **Docker** and **Docker Compose** for local development

## Local Development Environment

### Setup Environment
Install nodejs. Binaries and installers can be found on nodejs.org.
https://nodejs.org/en/download/

For macOS or Linux, Nodejs can usually be found in your preferred package manager.
https://nodejs.org/en/download/package-manager/

Depending on the Linux distribution, the Node Package Manager `npm` may need to be installed separately.

### Running the Project Locally

The backend and the frontend need to run on separate processes. The backend should be started first.
```bash
cd backend
npm ci
npm start
```
The backend should respond to a GET request on `localhost:8080`.

With the backend started, the frontend can be started.
```bash
cd frontend
npm ci
npm start
```
The frontend can be accessed at `localhost:3000`. If the frontend successfully connects to the backend, a message saying "SUCCESS" followed by a guid should be displayed on the screen. If the connection failed, an error message will be displayed on the screen.

### Local Testing with Docker Compose

You can also run the application locally using Docker Compose:

```bash
# Build and start the containers
docker compose up -d --build

# Stop the containers
docker compose down
```

The frontend will be available at `http://localhost:4000` and the backend at `http://localhost:8080`.

## AWS Infrastructure Deployment

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/feather-devops-challenge.git
cd feather-devops-challenge
```

### 2. Prepare Terraform Variables

Navigate to the infrastructure directory and create a `terraform.tfvars` file:

```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file to set appropriate values:

```hcl
# Required variables
aws_region        = "us-east-1"
environment       = "production"
ecs_cluster_name  = "feather-cluster"
vpc_cidr          = "10.10.0.0/16"
public_key        = "/path/to/your/id_ed25519.pub"

# Optional variables
instance_type     = "t3.medium" # Jenkins instance size
frontend_cpu      = 1024        # 1 vCPU
frontend_memory   = 2048        # 2 GB
backend_cpu       = 1024        # 1 vCPU
backend_memory    = 2048        # 2 GB
```

### 3. Deploy Infrastructure

Initialize, plan, and apply the Terraform configuration:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

The deployment will create:
- VPC with public and private subnets
- ECS Fargate cluster
- ECR repositories for Docker images
- Application Load Balancer
- Jenkins server on EC2

### 4. Access Jenkins and Configure CI/CD

After deployment, you can access the Jenkins server at the URL provided in the Terraform outputs.

## Setting Up Jenkins Pipelines

The repository includes four Jenkins pipeline definitions for building and deploying the application:

1. **Build and Push Pipelines**:
   - `/jenkins/build-and-push/Jenkinsfile.frontend`: Builds and pushes frontend Docker image
   - `/jenkins/build-and-push/Jenkinsfile.backend`: Builds and pushes backend Docker image

2. **Deployment Pipelines**:
   - `/jenkins/update-services/Jenkinsfile.frontend`: Updates frontend ECS service
   - `/jenkins/update-services/Jenkinsfile.backend`: Updates backend ECS service

### Creating Pipeline Jobs in Jenkins

1. **Configure Jenkins Credentials**:
   - Navigate to **Jenkins Dashboard** → **Manage Jenkins** → **Credentials** → **System** → **Global credentials** → **Add Credentials**
   - Create a credentials entry with:
     - **Kind**: Secret file
     - **File**: Upload the `jenkins_params.env` file from `infrastructure/jenkins-files/jenkins_params.env`
     - **ID**: `PROJECT_ENV`
     - **Description**: Environment variables for project pipelines

2. **Create Build Pipeline Jobs**:
   - From Jenkins dashboard, click **New Item**
   - Enter a name (e.g., `build-frontend`)
   - Select **Pipeline** and click **OK**
   - Under the **Pipeline** section:
     - Select **Pipeline script from SCM**
     - Set **SCM** to **Git**
     - Enter your repository URL
     - Specify the branch (e.g., `main`)
     - Set the **Script Path** to `jenkins/build-and-push/Jenkinsfile.frontend`
     - Save the configuration

3. **Create Deployment Pipeline Jobs**:
   - Repeat the process for deployment pipelines using script paths:
     - `jenkins/update-services/Jenkinsfile.frontend`
     - `jenkins/update-services/Jenkinsfile.backend`

4. **Configure Webhooks** (Optional):
   - For automated builds, configure webhooks in your Git repository to trigger Jenkins jobs on commits/PRs

## Continuous Deployment Workflow

The complete CI/CD workflow consists of:

1. Developer pushes code to the repository
2. Build pipeline is triggered, which:
   - Builds a Docker image
   - Tags it with build number
   - Pushes it to ECR repository
3. Deployment pipeline is triggered, which:
   - Updates ECS task definition with new image
   - Updates ECS service to use new task definition
   - Monitors deployment for success

## Configuration

The frontend has a configuration file at `frontend/src/config.js` that defines the URL to call the backend. This URL is used on `frontend/src/App.js#12`, where the front end will make the GET call during the initial load of the page.

The backend has a configuration file at `backend/config.js` that defines the host that the frontend will be calling from. This URL is used in the `Access-Control-Allow-Origin` CORS header, read in `backend/index.js#14`

In the AWS deployment:
- The frontend is configured to communicate with the backend service using ECS service discovery
- Environment variables are injected into container definitions to handle proper communication

## Destroying the Infrastructure

When you no longer need the infrastructure:

```bash
cd infrastructure
terraform destroy --auto-approve
```

⚠️ **Warning**: This will permanently delete all resources created by Terraform, including data in ECR repositories.

## Implementation Details

This solution implements several DevOps best practices:

1. **Infrastructure as Code**: All AWS resources are defined in Terraform
2. **Containerization**: Applications are containerized with Docker
3. **CI/CD Pipelines**: Automated build and deployment with Jenkins
4. **Service Discovery**: For internal service communication
5. **Load Balancing**: For high availability and traffic distribution
6. **Security**: Private subnets for backend services, public only for frontend
