#!/bin/bash
# Script to register ECS task definitions

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "Error: AWS CLI is not installed. Please install it first."
  exit 1
fi

# Set default region if not specified
AWS_REGION=${AWS_REGION:-$(aws configure get region)}
if [ -z "$AWS_REGION" ]; then
  echo "Error: AWS region not specified. Please set AWS_REGION environment variable."
  exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: Could not determine AWS account ID. Make sure you're authenticated."
  exit 1
fi

# Get Frontend ALB DNS name if needed
if [ -z "$FRONTEND_ALB_DNS_NAME" ]; then
  echo "Warning: FRONTEND_ALB_DNS_NAME not set. If you're registering backend task definition, this is required."
  echo "You can find this in the AWS console or by running:"
  echo "aws elbv2 describe-load-balancers --names feather-frontend-lb --query 'LoadBalancers[0].DNSName' --output text"
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Process frontend task definition
echo "Processing frontend task definition..."
sed -e "s/\${AWS_ACCOUNT_ID}/$AWS_ACCOUNT_ID/g" \
    -e "s/\${AWS_REGION}/$AWS_REGION/g" \
    frontend-task-definition.json > "$TEMP_DIR/frontend-task-definition.json"

# Process backend task definition
echo "Processing backend task definition..."
sed -e "s/\${AWS_ACCOUNT_ID}/$AWS_ACCOUNT_ID/g" \
    -e "s/\${AWS_REGION}/$AWS_REGION/g" \
    -e "s/\${FRONTEND_ALB_DNS_NAME}/$FRONTEND_ALB_DNS_NAME/g" \
    backend-task-definition.json > "$TEMP_DIR/backend-task-definition.json"

# Register task definitions
echo "Registering frontend task definition..."
FRONTEND_TASK_DEF_ARN=$(aws ecs register-task-definition \
  --cli-input-json "file://$TEMP_DIR/frontend-task-definition.json" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

echo "Registering backend task definition..."
BACKEND_TASK_DEF_ARN=$(aws ecs register-task-definition \
  --cli-input-json "file://$TEMP_DIR/backend-task-definition.json" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

# Clean up
rm -rf "$TEMP_DIR"
echo "Cleaned up temporary files"

# Output results
echo "======================"
echo "Task definitions registered successfully!"
echo "Frontend task definition ARN: $FRONTEND_TASK_DEF_ARN"
echo "Backend task definition ARN: $BACKEND_TASK_DEF_ARN"
echo "======================"
echo "To update your ECS services with these new task definitions, run:"
echo "aws ecs update-service --cluster feather --service feather-frontend-service --task-definition $FRONTEND_TASK_DEF_ARN --force-new-deployment"
echo "aws ecs update-service --cluster feather --service feather-backend-service --task-definition $BACKEND_TASK_DEF_ARN --force-new-deployment"
