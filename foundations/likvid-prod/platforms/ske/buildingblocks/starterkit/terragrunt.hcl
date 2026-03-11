include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "ske" {
  path = find_in_parent_folders("ske.hcl")
}

dependency "platform" {
  config_path = "../../platform"
  mock_outputs = {
    owned_by_workspace           = "mock-workspace"
    full_platform_identifier     = "mock-platform"
    landing_zone_dev_identifier  = "mock-lz-dev"
    landing_zone_prod_identifier = "mock-lz-prod"
  }
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/ske/ske-starterkit?ref=6bfe3de5b2ad56fea9e007900f25f16d8597ea1a"
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
  meshstack = {
    owning_workspace_identifier = dependency.platform.outputs.owned_by_workspace
  }
  full_platform_identifier     = dependency.platform.outputs.full_platform_identifier
  landing_zone_dev_identifier  = dependency.platform.outputs.landing_zone_dev_identifier
  landing_zone_prod_identifier = dependency.platform.outputs.landing_zone_prod_identifier
  hub                          = { git_ref = "6bfe3de5b2ad56fea9e007900f25f16d8597ea1a" }
  tags                         = {}
  notification_subscribers     = []
  project_tags_yaml            = <<-YAML
    dev:
      environment:
        - "dev"
    prod:
      environment:
        - "prod"
  YAML
}
