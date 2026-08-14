include "root" {
  path           = find_in_parent_folders("root.hcl")
  expose         = true
  merge_strategy = "shallow"
}

terraform {
  source = "${get_repo_root()}//platforms/oracle/sso"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

inputs = {
  oci_region             = "eu-frankfurt-1"
  oci_identity_domain_id = "ocid1.domain.oc1..aaaaaaaarluxawvelfgdkymjx5xobeqmgkco5g4zk5apsadyq2xp3yhb3u6a"
  oci_compartment_id     = "ocid1.tenancy.oc1..aaaaaaaaej7epkdwsl5rjnneas42fhgwudbfrovotuud5gflsqrlis5wdw2a"

  #azure Groups created in Prod tenant
  azure_ad_app_name             = "OCI Cloud SSO"
  azure_ad_admin_group_name     = "OCI-Administrators"
  azure_ad_developer_group_name = "OCI-Users"

  organization_name = "meshcloud"

  create_oci_policies = true
  oci_policy_statements = [
    "Allow group 'Default'/'Administrators' to manage all-resources in tenancy",
    "Allow group 'Default'/'OCI-Administrators' to manage all-resources in tenancy",
  ]
}
