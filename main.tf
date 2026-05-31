locals {
  common_tags = {
    Environment = "dev"
    Owner       = "mlops-course"
  }
}

module "argocd" {
  source = "./argocd"

  argocd_namespace     = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version
}

module "argocd_apps" {
  source = "./argocd-apps"

  argocd_namespace = var.argocd_namespace
  app_repo_url     = var.app_repo_url
  app_repo_branch  = var.app_repo_branch

  depends_on = [module.argocd]
}
