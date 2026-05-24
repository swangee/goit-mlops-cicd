output "argocd_namespace" {
  description = "Namespace, у якому встановлено Argo CD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
