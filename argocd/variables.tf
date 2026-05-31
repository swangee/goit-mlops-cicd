variable "argocd_namespace" {
  description = "Namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Версія Helm-чарту Argo CD (репозиторій argo-helm)"
  type        = string
  default     = "7.7.5"
}
