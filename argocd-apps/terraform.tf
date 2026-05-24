terraform {
  required_version = ">= 1.5"

  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 6.0, < 8.0"
    }
  }
}
