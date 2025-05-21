# ECS Task Definitions

This directory contains the AWS ECS task definitions for the Feather application.

## Files

- `frontend-task-definition.json`: Task definition for the frontend service
- `backend-task-definition.json`: Task definition for the backend service

## Usage

Before registering these task definitions, replace the following variables:

- `${AWS_ACCOUNT_ID}`: Your AWS account ID
- `${AWS_REGION}`: The AWS region you're deploying to (e.g., us-east-1)
- `${FRONTEND_ALB_DNS_NAME}`: DNS name of the frontend Application Load Balancer

### Register the task definitions

```bash
# Register the frontend task definition
aws ecs register-task-definition --cli-input-json file://frontend-task-definition.json

# Register the backend task definition
aws ecs register-task-definition --cli-input-json file://backend-task-definition.json
```

### Deploy as part of CI/CD

These task definitions can be used in your CI/CD pipeline by:

1. Replacing the variables with appropriate values (using environment variables or a script)
2. Registering the task definitions
3. Updating your ECS services to use the new task definition revisions

## Values from Terraform

These task definitions were created based on the Terraform configuration in `infrastructure/ecs-services.tf`.

The main parameters:

- Frontend:
  - CPU: 512 units
  - Memory: 1024 MB
  - Port: 3000
  
- Backend:
  - CPU: 256 units
  - Memory: 512 MB
  - Port: 8080

Both services use AWS Fargate launch type with awsvpc network mode.
