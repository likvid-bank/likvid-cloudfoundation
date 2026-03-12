# This lives in its own Terragrunt module because
# it depends on certmanager being applied first to create the ClusterIssuer CRD.
resource "kubernetes_manifest" "clusterissuer_letsencrypt_prod" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email  = "ske@meshcloud.io"
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
