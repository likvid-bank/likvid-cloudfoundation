include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

dependency "infra" {
  config_path = ".."
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "kubernetes" {
    host                   = "${dependency.infra.outputs.kube_host}"
    cluster_ca_certificate = base64decode("${dependency.infra.outputs.cluster_ca_certificate}")
    client_certificate     = base64decode("${dependency.infra.outputs.client_certificate}")
    client_key             = base64decode("${dependency.infra.outputs.client_key}")
  }

  provider "helm" {
    kubernetes = {
      host                   = "${dependency.infra.outputs.kube_host}"
      cluster_ca_certificate = base64decode("${dependency.infra.outputs.cluster_ca_certificate}")
      client_certificate     = base64decode("${dependency.infra.outputs.client_certificate}")
      client_key             = base64decode("${dependency.infra.outputs.client_key}")
    }
  }
  EOF
}
