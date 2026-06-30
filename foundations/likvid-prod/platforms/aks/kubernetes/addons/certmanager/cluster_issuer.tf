# Separate module because ClusterIssuer CRD must exist (via cert-manager) before this resource can be applied.
resource "kubernetes_manifest" "clusterissuer_letsencrypt_prod" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email  = "platform@likvid-bank.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-prod-account-key"
        }
        solvers = [{
          http01 = {
            ingress = {
              ingressClassName = "haproxy"
            }
          }
        }]
      }
    }
  }
}
