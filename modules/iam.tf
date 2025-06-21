# GitHub Actions service account for CI/CD
resource "google_service_account" "github_actions" {
  account_id   = "${var.service_name}-github-sa"
  display_name = "GitHub Actions SA for ${var.service_name}"
  description  = "Service account for GitHub Actions CI/CD pipeline"
  project      = var.project_id
}

# Grant minimum required permissions to GitHub Actions
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

# Service account key for GitHub Actions
resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Artifact Registry repository resource
resource "google_artifact_registry_repository" "giganoto_repo" {
  location      = var.region
  repository_id = "giganoto-repo"
  description   = "Docker repository for giganoto application"
  format        = "DOCKER"
  project       = var.project_id
  
  depends_on = [
    google_project_service.artifact_registry_api
  ]
}

# Artifact Registry permissions for GitHub Actions
resource "google_artifact_registry_repository_iam_member" "github_actions_artifactregistry" {
  location   = google_artifact_registry_repository.giganoto_repo.location
  repository = google_artifact_registry_repository.giganoto_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
  project    = var.project_id
}

# Note: Container Registry bucket and initial images are created manually or via CI/CD
# Removed null_resource to avoid Terraform syntax issues
