resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  # https://github.com/cert-manager/cert-manager/releases
  version          = "v1.19.4"
  create_namespace = false
  wait             = true
  timeout          = 300

  values = [
    yamlencode({
      crds = {
        enabled = true
        keep    = false # remove CRDs on destroy.
      }
    })
  ]
}
