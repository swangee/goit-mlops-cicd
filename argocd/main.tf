resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  # Дочекатись готовності Argo CD (CRD + контролери), щоб модуль argocd-apps
  # міг створювати ресурси поверх працюючого Argo CD.
  wait    = true
  timeout = 600

  values = [file("${path.module}/values/argocd-values.yaml")]
}
