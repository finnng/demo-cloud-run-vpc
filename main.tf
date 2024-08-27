terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.42.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "cloud-run-network"
  auto_create_subnetworks = false
}

# VPC subnet
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "cloud-run-subnet"
  ip_cidr_range = "10.0.0.0/28"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

# VPC connector
resource "google_vpc_access_connector" "connector" {
  name          = "vpc-con"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc_network.name
  region        = var.region
}

# Backend service account
resource "google_service_account" "demo_backend_sa" {
  account_id   = "demo-backend-sa"
  display_name = "Backend Service Account"
}

# Cloud Run backend service
resource "google_cloud_run_v2_service" "backend" {
  name     = "backend"
  location = var.region
  
  template {
    containers {
      image = var.backend_image
    }
    service_account = google_service_account.demo_backend_sa.email
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

# Frontend service account
resource "google_service_account" "demo_frontend_sa" {
  account_id   = "demo-frontend-sa"
  display_name = "Frontend Service Account"
}

# Grant VPC access user role to frontend service account
resource "google_project_iam_member" "demo_frontend_sa_vpc_access" {
  project = var.project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${google_service_account.demo_frontend_sa.email}"
}

# Cloud Run frontend service
resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend"
  location = var.region
  
  template {
    containers {
      image = var.frontend_image
      env {
        name  = "BACKEND_URL"
        value = google_cloud_run_v2_service.backend.uri
      }
    }
    service_account = google_service_account.demo_frontend_sa.email
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# IAM policy for backend service (private)
resource "google_cloud_run_service_iam_member" "backend_invoker" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  #member   = "serviceAccount:${google_service_account.demo_frontend_sa.email}"
  member   = "allUsers"
}

# IAM policy for frontend service (public)
resource "google_cloud_run_service_iam_member" "frontend_invoker" {
  location = google_cloud_run_v2_service.frontend.location
  service  = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
