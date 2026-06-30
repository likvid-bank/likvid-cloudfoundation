resource "kubernetes_namespace_v1" "haproxy_ingress" {
  metadata {
    name = "haproxy-ingress"
  }
}

resource "helm_release" "haproxy" {
  name       = "haproxy"
  namespace  = kubernetes_namespace_v1.haproxy_ingress.metadata[0].name
  repository = "https://haproxytech.github.io/helm-charts"
  chart      = "kubernetes-ingress"
  # https://github.com/haproxytech/helm-charts/blob/main/kubernetes-ingress/Chart.yaml
  version          = "1.49.0"
  create_namespace = false
  timeout          = 20 * 60

  values = [yamlencode({
    controller = {
      replicaCount = 2
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/healthz"
        }
      }
    }
  })]
}

# Read the LoadBalancer IP assigned by Azure after haproxy is up.
# Exposed as the haproxy_lb_ip output — point your DNS A record here.
data "kubernetes_service_v1" "haproxy_controller" {
  metadata {
    name      = "haproxy-kubernetes-ingress"
    namespace = kubernetes_namespace_v1.haproxy_ingress.metadata[0].name
  }

  depends_on = [helm_release.haproxy]
}
