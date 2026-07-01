include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//platforms/oracle/landingzones/sandbox"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

inputs = {
  tenancy_ocid            = dependency.bootstrap.outputs.tenancy_ocid
  region                  = "eu-frankfurt-1"
  parent_compartment_id   = dependency.bootstrap.outputs.foundation_compartment_ocid
  foundation              = dependency.bootstrap.outputs.foundation_name
  compartment_name        = "sandbox"
  compartment_description = "Sandbox environment for experimentation"
  enable_delete           = true
}
