include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "ske" {
  path = find_in_parent_folders("ske.hcl")
}

dependency "infra" {
  config_path = ".."
  mock_outputs = {
    kube_host              = "https://mock-host"
    cluster_ca_certificate = "bW9jaw=="
    client_certificate     = "bW9jaw=="
    client_key             = "bW9jaw=="
  }
}

# Generate helm + kubernetes providers wired up to the SKE cluster created in infra/.
# Both providers share the same set of credentials so all resources (namespaces, helm
# releases, manifests) target the same control-plane without extra wiring.
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
