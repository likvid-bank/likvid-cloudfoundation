provider "stackit" {
  default_region = "eu01"
}

locals {
  # meshStack writes the static FILE input `kubeconfig.yaml` next to the code.
  kubeconfig         = yamldecode(file("${path.module}/kubeconfig.yaml"))
  kubeconfig_cluster = one(local.kubeconfig.clusters).cluster
  kubeconfig_user    = one(local.kubeconfig.users).user
}

provider "kubernetes" {
  host                   = local.kubeconfig_cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig_cluster["certificate-authority-data"])

  token              = try(local.kubeconfig_user.token, null)
  client_certificate = try(base64decode(local.kubeconfig_user["client-certificate-data"]), null)
  client_key         = try(base64decode(local.kubeconfig_user["client-key-data"]), null)
}
