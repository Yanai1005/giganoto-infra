# CI/CDのためのGitHub Actions service account
resource "google_service_account" "github_actions" {
  account_id   = "${var.service_name}-github-sa"
  display_name = "GitHub Actions SA for ${var.service_name}"
  description  = "Service account for GitHub Actions CI/CD pipeline"
  project      = var.project_id
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/run.admin",                    # Cloud Run management
    "roles/storage.admin",                # Container Registry/Artifact Registry
    "roles/iam.serviceAccountUser",       # Service account usage
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_storage_bucket_iam_member" "github_actions_gcr" {
  bucket = "artifacts.${var.project_id}.appspot.com"
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.github_actions.email}"
  
  depends_on = [google_project_service.container_registry_api]
}

resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
