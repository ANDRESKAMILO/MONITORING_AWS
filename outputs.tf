output "dashboard_url" {
  value       = "https://app.${var.datadog_site}/dashboard/lists"
  description = "URL base para ver dashboards en Datadog"
}

output "aws_region_out" {
  value       = var.aws_region
  description = "Región de AWS utilizada"
} 