# Bootstrap ApplicationSet із git-генератором каталогів. Створюється через
# Argo CD API (provider "argocd", core-режим у root), тож plan-time перевірки
# CRD немає. Argo CD далі сам розгортає по Application на кожен підкаталог репо.
resource "argocd_application_set" "applications" {
  metadata {
    name      = "namespaces-appset"
    namespace = var.argocd_namespace
  }

  spec {
    generator {
      git {
        repo_url = var.app_repo_url
        revision = var.app_repo_branch

        directory {
          path = "applications/namespaces/*"
        }
      }
    }

    template {
      metadata {
        name = "ns-{{path.basename}}"
      }

      spec {
        project = "default"

        source {
          repo_url        = var.app_repo_url
          target_revision = var.app_repo_branch
          path            = "{{path}}"

          directory {
            recurse = true
          }
        }

        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "{{path.basename}}"
        }

        sync_policy {
          automated {
            prune     = true
            self_heal = true
          }
          sync_options = ["CreateNamespace=true"]
        }
      }
    }
  }
}
