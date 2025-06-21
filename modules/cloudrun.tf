resource "google_cloud_run_v2_service" "frontend" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    containers {
      # Container image deployed by GitHub Actions
      # Placeholder for initial deployment (will be overridden)
      image = "${var.image_name}:latest"
      
      ports {
        container_port = var.port
      }
      
      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
      
      # Environment variables
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
    
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  lifecycle {
    ignore_changes = [
      # GitHub Actions manages image and environment variables
      template[0].containers[0].image,
      template[0].containers[0].env,
    ]
  }
}

# Allow public access
resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_v2_service.frontend.name
  location = google_cloud_run_v2_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
