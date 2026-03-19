include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

dependency "meshstack" {
  config_path = ".."
  mock_outputs = {
    owning_workspace_identifier = "owning-workspace"
    location_identifier         = "mock-location"
  }
}

dependency "kubernetes" {
  config_path = "../../kubernetes"
  mock_outputs = {
    kubeconfig = {
      current-context = "mock-context"
      clusters = [
        {
          name = "mock-cluster"
          cluster = {
            server                     = "https://mock-kube-host"
            certificate-authority-data = "bW9jaw=="
          }
        }
      ]
      users = [
        {
          name = "mock-user"
          user = {
            client-certificate-data = "bW9jaw=="
            client-key-data         = "bW9jaw=="
          }
        }
      ]
      contexts = [
        {
          name = "mock-context"
          context = {
            cluster = "mock-cluster"
            user    = "mock-user"
          }
        }
      ]
    }
    provider_config = {
      host                   = "https://mock-kube-host"
      cluster_ca_certificate = "mock-ca-cert"
      client_certificate     = "mock-client-cert"
      client_key             = "mock-client-key"
    }
  }
}

# The kubernetes provider is configured here so both the root module (meshstack_platform)
# and the child backplane module inherit the same provider without needing extra wiring.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${try(dependency.kubernetes.outputs.provider_config.host, dependency.kubernetes.outputs.kubeconfig.clusters[0].cluster.server)}"
  cluster_ca_certificate = ${jsonencode(try(dependency.kubernetes.outputs.provider_config.cluster_ca_certificate, base64decode(dependency.kubernetes.outputs.kubeconfig.clusters[0].cluster["certificate-authority-data"])))}
  client_certificate     = ${jsonencode(try(dependency.kubernetes.outputs.provider_config.client_certificate, base64decode(dependency.kubernetes.outputs.kubeconfig.users[0].user["client-certificate-data"])))}
  client_key             = ${jsonencode(try(dependency.kubernetes.outputs.provider_config.client_key, base64decode(dependency.kubernetes.outputs.kubeconfig.users[0].user["client-key-data"])))}
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

inputs = {
  meshstack = dependency.meshstack.outputs
  kube_host = try(dependency.kubernetes.outputs.provider_config.host, dependency.kubernetes.outputs.kubeconfig.clusters[0].cluster.server)
}
