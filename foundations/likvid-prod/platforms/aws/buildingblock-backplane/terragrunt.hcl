# this is directly deployed with terragrunt because iam not not sure how to restructure it
# the account is deployed with meshstack called "buildingblock-backend"  
# and its only for a demo scenario. We will need to refactor this to a module in the future with
# more time 

#include "platform" {
#  path   = find_in_parent_folders("platform.hcl")
#  expose = true
#}

terraform {
source = "${get_repo_root()}//kit/aws/buildingblocks/automation"
}

# Generate a provider block for the AWS backend
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform { 
  backend "s3" {
    bucket         = "likvid-prod.bb-tf-backend"
    key            = "terraform/buildingblock-backplane/terraform.tfstate"
    region         = "eu-central-1"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "aws" {
  region = "eu-central-1"
  
  assume_role {
    #role_arn     = "arn:aws:iam::010438484429:role/AWSAdministratorAccess"
    session_name = "likvid-backend"
  }
}
EOF
}

inputs = {
  foundation_name = "likvid-prod"
  region          = "eu-central-1"
}
