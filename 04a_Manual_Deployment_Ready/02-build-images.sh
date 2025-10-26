#!/bin/bash
#
# Description:
#   This script builds and pushes Docker images for the frontend and backend to Google Container Registry.
#
# Usage:
#   ./02-build-images.sh

# --- Exit on error ---
set -e

# --- Load environment variables ---
source load-env.sh

# --- Check for required variables ---
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GCP_REGION" ]; then
  echo "Error: GCP_PROJECT_ID and GCP_REGION must be set in the .env file."
  exit 1
fi

# --- Configure Docker for GCR ---
echo "Configuring Docker for Google Container Registry..."
gcloud auth configure-docker

# --- Build and push frontend image ---
echo "Building and pushing frontend image..."
(cd frontend && \
  docker build -t gcr.io/$GCP_PROJECT_ID/storygen-frontend:latest . && \
  docker push gcr.io/$GCP_PROJECT_ID/storygen-frontend:latest)

# --- Build and push backend image ---
echo "Building and pushing backend image..."
(cd backend && \
  docker build -t gcr.io/$GCP_PROJECT_ID/storygen-backend:latest . && \
  docker push gcr.io/$GCP_PROJECT_ID/storygen-backend:latest)

echo "Image builds and pushes complete."
