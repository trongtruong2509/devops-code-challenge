# Feather DevOps Challenge Solution

## Overview
This repository contains a React frontend and an Express backend application deployed on AWS using containerization and CI/CD pipelines. The solution demonstrates how to deploy a simple web application using Docker containers and Jenkins for continuous integration and deployment.

## Project Structure

```
devops-code-challenge/
├── docker-compose.yaml        # Local development setup
├── README.md                  # Project documentation
├── backend/                   # Express backend application
│   ├── config.js              # Backend configuration
│   ├── Dockerfile             # Backend container definition
│   ├── index.js               # Main application file
│   └── package.json           # Node dependencies
├── frontend/                  # React frontend application
│   ├── docker-entrypoint.sh   # Container startup script
│   ├── Dockerfile             # Frontend container definition
│   ├── package.json           # Node dependencies
│   ├── proxy-server.js        # Development proxy server
│   ├── public/                # Static assets
│   └── src/                   # Application source code
└── jenkins/                   # Jenkins pipeline definitions
    ├── build-and-push/        # Build container images pipelines
    │   ├── Jenkinsfile.backend
    │   └── Jenkinsfile.frontend
    └── update-services/       # Deploy services pipelines
        ├── Jenkinsfile.backend
        └── Jenkinsfile.frontend
```

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

## Jenkins CI/CD Pipelines

The repository includes four Jenkins pipeline definitions for building and deploying the application:

1. **Build and Push Pipelines**:
   - `/jenkins/build-and-push/Jenkinsfile.frontend`: Builds and pushes frontend Docker image
   - `/jenkins/build-and-push/Jenkinsfile.backend`: Builds and pushes backend Docker image

2. **Deployment Pipelines**:
   - `/jenkins/update-services/Jenkinsfile.frontend`: Updates frontend ECS service
   - `/jenkins/update-services/Jenkinsfile.backend`: Updates backend ECS service

### Setting Up Pipeline Jobs in Jenkins

1. **Configure Jenkins Credentials**:
   - Navigate to **Jenkins Dashboard** → **Manage Jenkins** → **Credentials** → **System** → **Global credentials** → **Add Credentials**
   - Create a credentials entry with:
     - **Kind**: Secret file
     - **File**: Upload a file containing the required environment variables
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
   - To automate deployment after successful builds:
     - In each deployment job, go to **Configure** → **Build Triggers**
     - Select **Build after other projects are built**
     - Enter the corresponding build job name (e.g., `build-frontend` for the frontend deployment)
     - Select **Trigger only if build is stable** to ensure only successful builds trigger deployment

4. **Configure Webhooks** (Optional):
   - For automated builds, configure webhooks in your Git repository to trigger Jenkins jobs on commits/PRs

## Continuous Deployment Workflow

The complete CI/CD workflow consists of:

1. Developer pushes code to the repository
2. Build pipeline is triggered, which:
   - Builds a Docker image
   - Tags it with build number
   - Pushes it to ECR repository
3. Deployment pipeline is automatically triggered upon successful build completion, which:
   - Updates ECS task definition with new image
   - Updates ECS service to use new task definition
   - Monitors deployment for success

## Configuration

The frontend has a configuration file at `frontend/src/config.js` that defines the URL to call the backend. This URL is used on `frontend/src/App.js#12`, where the front end will make the GET call during the initial load of the page.

The backend has a configuration file at `backend/config.js` that defines the host that the frontend will be calling from. This URL is used in the `Access-Control-Allow-Origin` CORS header, read in `backend/index.js#14`

In the AWS deployment:
- The frontend is configured to communicate with the backend service using service discovery
- Environment variables are injected into container definitions to handle proper communication
