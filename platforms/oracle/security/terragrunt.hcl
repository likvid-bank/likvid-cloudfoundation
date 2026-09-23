include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//platforms/oracle/security"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

inputs = {
  tenancy_ocid                = dependency.bootstrap.outputs.tenancy_ocid
  foundation_compartment_ocid = dependency.bootstrap.outputs.foundation_compartment_ocid
}
