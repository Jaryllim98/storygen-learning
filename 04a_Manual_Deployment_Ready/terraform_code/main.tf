# --- Providers ---
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Service Accounts ---
resource "google_service_account" "backend_service_account" {
  account_id   = "storygen-backend-sa"
  display_name = "StoryGen Backend Service Account"
}

# --- Cloud Run Services ---
module "frontend-service" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2?ref=v0.20.1"
  project_id   = var.gcp_project_id
  location     = var.gcp_region
  service_name = "storygen-frontend"

  containers = [{
    container_image = var.frontend_image
    env_vars = {
      NEXT_PUBLIC_BACKEND_URL = module.backend-service.service_url
    }
  }]

  service_account_project_roles = ["roles/run.invoker"]
}

module "backend-service" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2?ref=v0.20.1"
  project_id   = var.gcp_project_id
  location     = var.gcp_region
  service_name = "storygen-backend"
  service_account_email = google_service_account.backend_service_account.email

  containers = [{
    container_image = var.backend_image
  }]

  service_account_project_roles = [
    "roles/aiplatform.user",
    "roles/storage.objectAdmin"
  ]
}

# --- Storage Bucket ---
resource "google_storage_bucket" "generated-images-bucket" {
  name          = "${var.gcp_project_id}-storygen-images"
  location      = var.gcp_region
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
}

# --- IAM ---
resource "google_storage_bucket_iam_member" "backend-storage-admin" {
  bucket = google_storage_bucket.generated-images-bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backend_service_account.email}"
}
