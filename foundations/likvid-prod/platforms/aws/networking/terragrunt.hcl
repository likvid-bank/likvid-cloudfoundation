include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/aws/networking"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

dependency "organization" {
  config_path = "../organization"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${dependency.bootstrap.outputs.networking_account_id}:role/OrganizationAccountAccessRole"
  }
  allowed_account_ids = ["${dependency.bootstrap.outputs.networking_account_id}"]
}
EOF
}

inputs = {
  tgw_name                              = "likvid-tgw"
  tgw_description                       = "this is the central transit gateway for likvid"
  enable_auto_accept_shared_attachments = true
  ram_principals                        = [dependency.organization.outputs.landingzones_ou_arn]
  transit_gateway_cidr_blocks           = ["10.99.0.0/24"]
  #ram_tags = ""
}
