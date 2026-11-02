removed {
  from = helm_release.cert_manager
  lifecycle {
    destroy = false
  }
}

removed {
  from = helm_release.haproxy
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_namespace_v1.cert_manager
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_namespace_v1.haproxy_ingress
  lifecycle {
    destroy = false
  }
}
