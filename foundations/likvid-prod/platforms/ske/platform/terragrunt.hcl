include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "postgres" {
  config_path = "../postgres"

  mock_outputs = {
    instance_definition_ref  = { kind = "meshBuildingBlockDefinition", uuid = "00000000-0000-0000-0000-000000000000" }
    connector_definition_ref = { kind = "meshBuildingBlockDefinition", uuid = "00000000-0000-0000-0000-000000000001" }
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "devops-platform"
}
EOF
}

inputs = {
  hub = include.hub.locals
  additional_federated_building_block_definitions = [
    dependency.postgres.outputs.instance_definition_ref,
    dependency.postgres.outputs.connector_definition_ref,
  ]
}
