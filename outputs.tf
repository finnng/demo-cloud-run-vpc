output "frontend_url" {
  value       = google_cloud_run_v2_service.frontend.uri
  description = "URL of the frontend Cloud Run service"
}

output "backend_url" {
  value       = google_cloud_run_v2_service.backend.uri
  description = "URL of the backend Cloud Run service (not publicly accessible)"
}
