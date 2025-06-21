terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "asia-northeast1"
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "giganoto"
}

variable "image_name" {
  description = "Container image name without tag"
  type        = string
}

variable "port" {
  description = "Container port number"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "env_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

module "giganoto_infrastructure" {
  source = "./modules"
  
  project_id    = var.project_id
  region        = var.region
  service_name  = var.service_name
  image_name    = var.image_name
  port          = var.port
  cpu_limit     = var.cpu_limit
  memory_limit  = var.memory_limit
  max_instances = var.max_instances
  min_instances = var.min_instances
  env_vars      = var.env_vars
}

output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = module.giganoto_infrastructure.cloud_run_url
}

output "github_actions_service_account_email" {
  description = "Email of the GitHub Actions service account"
  value       = module.giganoto_infrastructure.github_actions_service_account_email
}

output "github_actions_service_account_key" {
  description = "GitHub Actions service account key (JSON format, Base64 encoded)"
  value       = module.giganoto_infrastructure.github_actions_service_account_key
  sensitive   = true
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = module.giganoto_infrastructure.artifact_registry_url
}

output "service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = module.giganoto_infrastructure.service_url
}
