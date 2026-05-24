terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }

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

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "mlops-course"
      ManagedBy = "terraform"
      Component = "eks-vpc-cluster"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Підключення до вже встановленого argocd-server через port-forward.
# Креди до кластера — inline (блок kubernetes), пароль — з initial-admin-secret.
# plain_text = true, бо argocd-server запущено з --insecure (HTTP).
provider "argocd" {
  port_forward_with_namespace = var.argocd_namespace
  username                    = "admin"
  password                    = data.kubernetes_secret.argocd_admin.data["password"]
  plain_text                  = true

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
