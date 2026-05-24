output "application_set_name" {
  description = "Імʼя bootstrap ApplicationSet"
  value       = argocd_application_set.applications.metadata[0].name
}
