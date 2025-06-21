output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.frontend.uri
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.frontend.name
}

output "github_actions_service_account_email" {
  description = "GitHub Actions service account email"
  value       = google_service_account.github_actions.email
}

output "github_actions_service_account_key" {
  description = "GitHub Actions service account key (JSON format, Base64 encoded)"
  value       = google_service_account_key.github_actions_key.private_key
  sensitive   = true
}

output "container_registry_url" {
  description = "Container Registry URL"
  value       = "gcr.io/${var.project_id}"
}

output "image_full_name" {
  description = "Full container image name"
  value       = var.image_name
}
