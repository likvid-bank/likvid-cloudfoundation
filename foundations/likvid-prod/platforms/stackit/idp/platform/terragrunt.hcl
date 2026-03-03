include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "idp" {
  path = find_in_parent_folders("idp.hcl")
}

dependency "infra" {
  config_path = "../infra"
}

# The kubernetes provider is configured here so both the root module (meshstack_platform)
# and the child backplane module inherit the same provider without needing extra wiring.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${dependency.infra.outputs.kube_host}"
  cluster_ca_certificate = base64decode("${dependency.infra.outputs.cluster_ca_certificate}")
  client_certificate     = base64decode("${dependency.infra.outputs.client_certificate}")
  client_key             = base64decode("${dependency.infra.outputs.client_key}")
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

inputs = {
  kube_host = dependency.infra.outputs.kube_host
}
