#!/bin/bash
#
# Description:
#   This script deploys the infrastructure using Terraform.
#
# Usage:
#   ./03-deploy-infrastructure.sh

# --- Exit on error ---
set -e

# --- Load environment variables ---
source load-env.sh

# --- Check for required variables ---
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GCP_REGION" ]; then
  echo "Error: GCP_PROJECT_ID and GCP_REGION must be set in the .env file."
  exit 1
fi

# --- Initialize Terraform ---
echo "Initializing Terraform..."
(cd terraform_code && terraform init)

# --- Plan and apply Terraform changes ---
echo "Planning and applying Terraform changes..."
(cd terraform_code && \
  terraform plan -out=tfplan -var="gcp_project_id=$GCP_PROJECT_ID" -var="gcp_region=$GCP_REGION" -var="frontend_image=gcr.io/$GCP_PROJECT_ID/storygen-frontend:latest" -var="backend_image=gcr.io/$GCP_PROJECT_ID/storygen-backend:latest" && \
  terraform apply -auto-approve tfplan)

# --- Get backend service account email ---
BACKEND_SERVICE_ACCOUNT_EMAIL=$(cd terraform_code && terraform output -raw backend_service_account_email)

# --- Set environment variables for the backend service ---
echo "Setting environment variables for the backend service..."
gcloud run services update storygen-backend \
  --platform managed \
  --region $GCP_REGION \
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$GCP_PROJECT_ID" \
  --set-env-vars "BUCKET_NAME=${GCP_PROJECT_ID}-storygen-images"

echo "Infrastructure deployment complete."