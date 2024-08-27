variable "project_id" {
  description = "The GCP project ID"
}

variable "region" {
  description = "The region to deploy the services"
  default     = "us-central1"
}

variable "frontend_image" {
  description = "The Docker image for the frontend service"
}

variable "backend_image" {
  description = "The Docker image for the backend service"
}
