# EKS connection details for the kubernetes & helm providers in terraform.tf.
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Початковий admin-пароль Argo CD — для автентифікації провайдера argocd.
# Secret зʼявляється лише після встановлення Argo CD (звідси depends_on),
# тому на першому прогоні argocd-ресурси застосовуються окремою фазою.
data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }

  depends_on = [module.argocd]
}
