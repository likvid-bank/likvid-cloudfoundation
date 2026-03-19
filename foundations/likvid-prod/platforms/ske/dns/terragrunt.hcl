include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

dependency "meshstack" {
  config_path = "../meshstack"
  mock_outputs = {
    stackit_project_id = "00000000-0000-0000-0000-000000000000"
  }
}

dependency "addons" {
  config_path = "../kubernetes/addons"
  mock_outputs = {
    haproxy_lb_ip = "127.0.0.1"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  default_region        = "eu01"
  service_account_key   = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
  enable_beta_resources = true
}
EOF
}

inputs = {
  stackit_project_id = dependency.meshstack.outputs.stackit_project_id
  dns_name           = "likvid"
  haproxy_lb_ip      = dependency.addons.outputs.haproxy_lb_ip
}
