provider "stackit" {
  default_region = "eu01"
}

provider "vault" {
  address = var.vault_reader.address
  # A Secrets Manager user may not create the child token the provider asks for by default.
  skip_child_token = true

  auth_login_userpass {
    username = var.vault_reader.username
    password = var.vault_reader.password
  }
}

ephemeral "vault_kv_secret_v2" "kubeconfig" {
  mount = var.vault_reader.mount
  name  = var.kubeconfig_path
}

locals {
  admin_kubeconfig = yamldecode(ephemeral.vault_kv_secret_v2.kubeconfig.data.kubeconfig)
}

provider "kubernetes" {
  host                   = one(local.admin_kubeconfig.clusters).cluster.server
  cluster_ca_certificate = base64decode(one(local.admin_kubeconfig.clusters).cluster["certificate-authority-data"])
  token                  = one(local.admin_kubeconfig.users).user.token
}
