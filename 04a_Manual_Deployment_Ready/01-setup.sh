#!/bin/bash
#
# Description:
#   This script sets up the environment for deployment, including Google Cloud authentication and configuration.
#
# Usage:
#   ./01-setup.sh

# --- Exit on error ---
set -e

# --- Load environment variables ---
source load-env.sh

# --- Check for required variables ---
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GCP_REGION" ]; then
  echo "Error: GCP_PROJECT_ID and GCP_REGION must be set in the .env file."
  exit 1
fi

# --- Authenticate with Google Cloud ---
echo "Authenticating with Google Cloud..."
gcloud auth login
gcloud config set project $GCP_PROJECT_ID

# --- Enable required services ---
echo "Enabling required Google Cloud services..."
gcloud services enable \
  run.googleapis.com \
  containerregistry.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  aiplatform.googleapis.com \
  storage-api.googleapis.com

# --- Create GCS bucket for Terraform state ---
echo "Creating GCS bucket for Terraform state..."
gsutil mb -p $GCP_PROJECT_ID gs://storygen-terraform-state

echo "Setup complete."