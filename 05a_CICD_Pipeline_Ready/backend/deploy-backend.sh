#!/bin/bash

set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./deploy-backend.sh [staging|prod]"
  exit 1
fi

SERVICE_NAME="storygen-backend-$ENV"

COMMIT_SHA=$(git rev-parse --short HEAD)

gcloud builds submit . --config cloudbuild.yaml --substitutions=\
  _REGION=us-central1,\\
  _REPO_NAME=storygen-repo,\\
  _SERVICE_NAME=$SERVICE_NAME, மூல
  COMMIT_SHA=$COMMIT_SHA
