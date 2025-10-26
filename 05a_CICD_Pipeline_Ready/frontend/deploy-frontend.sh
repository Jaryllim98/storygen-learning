#!/bin/bash

set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./deploy-frontend.sh [staging|prod]"
  exit 1
fi

SERVICE_NAME="storygen-frontend-$ENV"

# The backend URL will be passed as a substitution variable to the build
if [ "$ENV" == "prod" ]; then
  BACKEND_URL="<your-prod-backend-url>"
else
  BACKEND_URL="<your-staging-backend-url>"
fi

COMMIT_SHA=$(git rev-parse --short HEAD)

gcloud builds submit . --config cloudbuild.yaml --substitutions=\
  _REGION=us-central1,\ 
  _REPO_NAME=storygen-repo,\ 
  _SERVICE_NAME=$SERVICE_NAME,\ 
  _BACKEND_URL=$BACKEND_URL,\ 
  COMMIT_SHA=$COMMIT_SHA