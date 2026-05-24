variable "argocd_namespace" {
  description = "Namespace, у якому працює Argo CD (тут створюються ApplicationSet'и)"
  type        = string
}

variable "app_repo_url" {
  description = "Публічний Git-репозиторій з маніфестами застосунків"
  type        = string
}

variable "app_repo_branch" {
  description = "Гілка репозиторію з маніфестами"
  type        = string
}
