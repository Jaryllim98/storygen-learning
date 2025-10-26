variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region."
  type        = string
}

variable "frontend_image" {
  description = "The Docker image for the frontend."
  type        = string
}

variable "backend_image" {
  description = "The Docker image for the backend."
  type        = string
}