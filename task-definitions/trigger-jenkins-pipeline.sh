#!/bin/bash
# Script to trigger Jenkins ECS deployment pipelines from the command line
# Requires jenkins-cli.jar to be available

# Configuration
JENKINS_URL=${JENKINS_URL:-"http://localhost:8080"}
JENKINS_USER=${JENKINS_USER:-"admin"}
JENKINS_API_TOKEN=${JENKINS_API_TOKEN:-""}  # Generate this in Jenkins user configuration
JENKINS_CLI_JAR=${JENKINS_CLI_JAR:-"jenkins-cli.jar"}

# Check if jenkins-cli.jar exists
if [ ! -f "$JENKINS_CLI_JAR" ]; then
  echo "Downloading jenkins-cli.jar..."
  curl -o "$JENKINS_CLI_JAR" "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
fi

# Function to print usage information
usage() {
  echo "Usage: $0 [frontend|backend|full] [options]"
  echo ""
  echo "Deployment types:"
  echo "  frontend   - Deploy only the frontend service"
  echo "  backend    - Deploy only the backend service"
  echo "  full       - Deploy both backend and frontend services"
  echo ""
  echo "Options:"
  echo "  -r, --region REGION            AWS Region (default: us-east-1)"
  echo "  -a, --account-id ACCOUNT_ID    AWS Account ID (required)"
  echo "  -c, --cluster CLUSTER          ECS Cluster name (default: feather)"
  echo "  -b, --backend-tag TAG          Backend image tag (default: latest)"
  echo "  -f, --frontend-tag TAG         Frontend image tag (default: latest)"
  echo "  -d, --dns-name DNS_NAME        Frontend ALB DNS name (required for backend)"
  echo "  -n, --count COUNT              Desired task count (default: 1)"
  echo "  -h, --help                     Display this help message"
  echo ""
  echo "Environment variables:"
  echo "  JENKINS_URL         - Jenkins URL (default: http://localhost:8080)"
  echo "  JENKINS_USER        - Jenkins username (default: admin)"
  echo "  JENKINS_API_TOKEN   - Jenkins API token (required)"
  echo "  JENKINS_CLI_JAR     - Path to jenkins-cli.jar (default: ./jenkins-cli.jar)"
  echo ""
  echo "Example:"
  echo "  $0 full -a 123456789012 -d myapp-lb.us-east-1.elb.amazonaws.com -b v1.0.0 -f v1.0.0"
  exit 1
}

# Parse deployment type
if [ -z "$1" ]; then
  usage
fi

DEPLOYMENT_TYPE="$1"
shift

# Default values
AWS_REGION="us-east-1"
ECS_CLUSTER="feather"
BACKEND_IMAGE_TAG="latest"
FRONTEND_IMAGE_TAG="latest"
DESIRED_COUNT="1"

# Parse options
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -r|--region)
      AWS_REGION="$2"
      shift 2
      ;;
    -a|--account-id)
      AWS_ACCOUNT_ID="$2"
      shift 2
      ;;
    -c|--cluster)
      ECS_CLUSTER="$2"
      shift 2
      ;;
    -b|--backend-tag)
      BACKEND_IMAGE_TAG="$2"
      shift 2
      ;;
    -f|--frontend-tag)
      FRONTEND_IMAGE_TAG="$2"
      shift 2
      ;;
    -d|--dns-name)
      FRONTEND_ALB_DNS_NAME="$2"
      shift 2
      ;;
    -n|--count)
      DESIRED_COUNT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Check required parameters
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS Account ID is required. Use -a or --account-id option."
  usage
fi

if [ "$DEPLOYMENT_TYPE" == "backend" ] || [ "$DEPLOYMENT_TYPE" == "full" ]; then
  if [ -z "$FRONTEND_ALB_DNS_NAME" ]; then
    echo "Error: Frontend ALB DNS name is required for backend deployment. Use -d or --dns-name option."
    usage
  fi
fi

if [ -z "$JENKINS_API_TOKEN" ]; then
  echo "Error: Jenkins API token is required. Set the JENKINS_API_TOKEN environment variable."
  usage
fi

# Function to trigger a Jenkins job
trigger_job() {
  local job_name="$1"
  local parameters="$2"
  
  echo "Triggering job: $job_name"
  echo "Parameters: $parameters"
  
  java -jar "$JENKINS_CLI_JAR" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_API_TOKEN" \
    build "$job_name" -p "$parameters" -v
  
  return $?
}

# Execute deployment based on type
case "$DEPLOYMENT_TYPE" in
  frontend)
    PARAMETERS="AWS_REGION=$AWS_REGION AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID IMAGE_TAG=$FRONTEND_IMAGE_TAG ECS_CLUSTER=$ECS_CLUSTER SERVICE_NAME=${ECS_CLUSTER}-frontend-service BACKEND_URL=http://${ECS_CLUSTER}-backend.${ECS_CLUSTER}.internal:8080 DESIRED_COUNT=$DESIRED_COUNT"
    trigger_job "feather-frontend-deployment" "$PARAMETERS"
    ;;
  backend)
    PARAMETERS="AWS_REGION=$AWS_REGION AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID IMAGE_TAG=$BACKEND_IMAGE_TAG ECS_CLUSTER=$ECS_CLUSTER SERVICE_NAME=${ECS_CLUSTER}-backend-service FRONTEND_ALB_DNS_NAME=$FRONTEND_ALB_DNS_NAME DESIRED_COUNT=$DESIRED_COUNT"
    trigger_job "feather-backend-deployment" "$PARAMETERS"
    ;;
  full)
    PARAMETERS="AWS_REGION=$AWS_REGION AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID BACKEND_IMAGE_TAG=$BACKEND_IMAGE_TAG FRONTEND_IMAGE_TAG=$FRONTEND_IMAGE_TAG ECS_CLUSTER=$ECS_CLUSTER BACKEND_SERVICE_NAME=${ECS_CLUSTER}-backend-service FRONTEND_SERVICE_NAME=${ECS_CLUSTER}-frontend-service FRONTEND_ALB_DNS_NAME=$FRONTEND_ALB_DNS_NAME DESIRED_COUNT=$DESIRED_COUNT"
    trigger_job "feather-full-deployment" "$PARAMETERS"
    ;;
  *)
    echo "Error: Invalid deployment type. Use 'frontend', 'backend', or 'full'."
    usage
    ;;
esac
