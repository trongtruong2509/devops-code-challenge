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

## Deployment Steps

# Setup your environment
Install nodejs. Binaries and installers can be found on nodejs.org.
https://nodejs.org/en/download/

For macOS or Linux, Nodejs can usually be found in your preferred package manager.
https://nodejs.org/en/download/package-manager/

Depending on the Linux distribution, the Node Package Manager `npm` may need to be installed separately.

## Local Development Environment

# Running the project
The backend and the frontend will need to run on separate processes. The backend should be started first.
```
cd backend
npm ci
npm start
```
The backend should response to a GET request on `localhost:8080`.

With the backend started, the frontend can be started.
```
cd frontend
npm ci
npm start
```
The frontend can be accessed at `localhost:3000`. If the frontend successfully connects to the backend, a message saying "SUCCESS" followed by a guid should be displayed on the screen.  If the connection failed, an error message will be displayed on the screen.

# Configuration
The frontend has a configuration file at `frontend/src/config.js` that defines the URL to call the backend. This URL is used on `frontend/src/App.js#12`, where the front end will make the GET call during the initial load of the page.

The backend has a configuration file at `backend/config.js` that defines the host that the frontend will be calling from. This URL is used in the `Access-Control-Allow-Origin` CORS header, read in `backend/index.js#14`

# Optional Extras
The core requirement for this challenge is to get the provided application up and running for consumption over the public internet. That being said, there are some opportunities in this code challenge to demonstrate your skill sets that are above and beyond the core requirement.

A few examples of extras for this coding challenge:
1. Dockerizing the application
2. Scripts to set up the infrastructure
3. Providing a pipeline for the application deployment
4. Running the application in a serverless environment

This is not an exhaustive list of extra features that could be added to this code challenge. At the end of the day, this section is for you to demonstrate any skills you want to show that’s not captured in the core requirement.
