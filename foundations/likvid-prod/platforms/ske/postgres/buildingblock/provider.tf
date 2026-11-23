provider "stackit" {
  default_region = "eu01"
  experiments    = ["ske"]
}

# Opened on every run and never stored, so a later run, a destroy too, gets a valid one.
ephemeral "stackit_ske_kubeconfig" "this" {
  project_id   = var.ske_project_id
  cluster_name = var.ske_cluster_name
  expiration   = 3600
}

locals {
  ske_kubeconfig = yamldecode(ephemeral.stackit_ske_kubeconfig.this.kube_config)
}

provider "kubernetes" {
  host                   = one(local.ske_kubeconfig.clusters).cluster.server
  cluster_ca_certificate = base64decode(one(local.ske_kubeconfig.clusters).cluster["certificate-authority-data"])
  client_certificate     = base64decode(one(local.ske_kubeconfig.users).user["client-certificate-data"])
  client_key             = base64decode(one(local.ske_kubeconfig.users).user["client-key-data"])
}
