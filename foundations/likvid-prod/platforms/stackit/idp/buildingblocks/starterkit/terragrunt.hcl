include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "idp" {
  path = find_in_parent_folders("idp.hcl")
}

dependency "platform" {
  config_path = "../../platform"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

inputs = {
  owned_by_workspace           = dependency.platform.outputs.owned_by_workspace
  full_platform_identifier     = dependency.platform.outputs.full_platform_identifier
  landing_zone_dev_identifier  = dependency.platform.outputs.landing_zone_dev_identifier
  landing_zone_prod_identifier = dependency.platform.outputs.landing_zone_prod_identifier
}
