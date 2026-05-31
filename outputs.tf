output "kubeconfig_context" {
  description = "Kubeconfig context used by Terraform"
  value       = var.kubeconfig_context
}

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = var.argocd_namespace
}
