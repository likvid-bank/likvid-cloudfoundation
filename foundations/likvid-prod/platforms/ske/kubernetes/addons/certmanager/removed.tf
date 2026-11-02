removed {
  from = kubernetes_manifest.clusterissuer_letsencrypt_prod
  lifecycle {
    destroy = false
  }
}
