include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//platforms/oracle/bootstrap"
}

inputs = {
  tenancy_ocid                = "ocid1.tenancy.oc1..aaaaaaaaej7epkdwsl5rjnneas42fhgwudbfrovotuud5gflsqrlis5wdw2a"
  foundation_compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa2yincyn6x4tusxfluj34uudupphdlpweahpof3jbjwwtaoudkhqq"
  foundation_name             = "likvid"
  home_region                 = "eu-frankfurt-1"

  platform_engineers_group = {
    name    = "platform-engineers"
    members = []
  }
}
