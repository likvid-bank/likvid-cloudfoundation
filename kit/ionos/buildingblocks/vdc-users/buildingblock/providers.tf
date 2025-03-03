terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "6.6.8"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "ionoscloud" {
  #  we encourage users to use token authentication for security reasons
  contract_number = var.contract_id
  #  optional, does not need to be configured in most cases
}

terraform {
  backend "s3" {
    bucket = "buildingblocks-tfstates-p32kj" # Must match what's configured in automation backend
    key    = "terraform/ionos-vdc-users"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/LikvidBuildingBlockServiceRole" # Must match what's configured in automation backend
  }
}
