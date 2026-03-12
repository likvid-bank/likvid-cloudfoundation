include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "ske" {
  path = find_in_parent_folders("tfstate.hcl")
}

dependency "kubernetes" {
  config_path = "../kubernetes"
  mock_outputs = {
    kube_host              = "https://mock-host"
    cluster_ca_certificate = "bW9jaw=="
    client_certificate     = "bW9jaw=="
    client_key             = "bW9jaw=="
  }
}

# The kubernetes provider is configured here so both the root module (meshstack_platform)
# and the child backplane module inherit the same provider without needing extra wiring.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${dependency.kubernetes.outputs.kube_host}"
  cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_ca_certificate}")
  client_certificate     = base64decode("${dependency.kubernetes.outputs.client_certificate}")
  client_key             = base64decode("${dependency.kubernetes.outputs.client_key}")
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

inputs = {
  kube_host = dependency.kubernetes.outputs.kube_host
}
