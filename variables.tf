variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubeconfig context to use (e.g. docker-desktop)"
  type        = string
  default     = "docker-desktop"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "docker-desktop"
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version (argo-helm repo)"
  type        = string
  default     = "7.7.5"
}

variable "app_repo_url" {
  description = "Public Git repo with application manifests"
  type        = string
  default     = "https://github.com/swangee/goit-mlops-cicd.git"
}

variable "app_repo_branch" {
  description = "Branch of the manifests repo"
  type        = string
  default     = "lesson9"
}
