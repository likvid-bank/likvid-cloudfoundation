include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

// this is not a standard platform module that uses a kit module, instead we call this a "tenant module"
// that contains its own terraform code and just pulls in plain terraform modules (building blocks) for reusable modules
terraform {
  source = "./"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

dependency "networking" {
  config_path = "../../networking"
}

dependency "on_prem" {
  config_path = "../../landingzones/on-prem"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  alias  = "management"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${include.platform.locals.platform.aws.accountId}:role/OrganizationAccountAccessRole"
  }
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}

provider "aws" {
  alisas = "networking"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${dependency.bootstrap.outputs.networking_account_id}:role/OrganizationAccountAccessRole"
  }
  allowed_account_ids = ["${dependency.bootstrap.outputs.networking_account_id}"]
}
EOF
}

inputs = {
  on_prem_ou = dependency.on_prem.outputs.prod_ou_id
  # hub_rg                   = dependency.networking.outputs.hub_rg
  # hub_vnet                 = dependency.networking.outputs.hub_vnet
  # spoke_owner_principal_id = dependency.networking.outputs.network_admins_azuread_group_id
}
