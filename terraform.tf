terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.29, < 3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13, < 3.0"
    }

    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 6.0, < 8.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

provider "argocd" {
  port_forward_with_namespace = var.argocd_namespace
  username                    = "admin"
  password                    = data.kubernetes_secret.argocd_admin.data["password"]
  plain_text                  = true
}
