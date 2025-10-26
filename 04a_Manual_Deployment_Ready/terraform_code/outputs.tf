output "frontend_url" {
  description = "The URL of the frontend service."
  value       = module.frontend-service.service_url
}

output "backend_url" {
  description = "The URL of the backend service."
  value       = module.backend-service.service_url
}

output "backend_service_account_email" {
  description = "The email of the backend service account."
  value       = google_service_account.backend_service_account.email
}