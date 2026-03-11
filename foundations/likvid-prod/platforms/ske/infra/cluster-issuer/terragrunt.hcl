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

dependency "resources" {
  config_path  = "../addons"
  skip_outputs = true # only needed for apply ordering; no outputs consumed
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
EOF
}
