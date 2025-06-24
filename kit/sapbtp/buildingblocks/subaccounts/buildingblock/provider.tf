terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.8.0"
    }
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "0.7.1"
    }
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "5.65.0"
    # }
  }
}
# # we are using the building block backend from AWS Automation
# terraform {
#   backend "s3" {
#     bucket = "buildingblocks-tfstates-p32kj" # Must match what's configured in automation backend
#     key    = "terraform/sapbtp-subaccount"
#     region = "eu-central-1"
#   }
# }

# provider "aws" {
#   region = "eu-central-1"

#   assume_role {
#     role_arn = "arn:aws:iam::${var.account_id}:role/LikvidBuildingBlockServiceRole" # Must match what's configured in automation backend
#   }
# }

provider "btp" {
  globalaccount = var.globalaccount
  # using ENV vars in meshStack for username and password
}

provider "meshstack" {
  endpoint = "https://federation.demo.meshcloud.io"
}
