terraform {
  required_providers {
    restapi = {
      source  = "mastercard/restapi"
      version = "1.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
provider "ionoscloud" {
#  we encourage users to use token authentication for security reasons
 contract_number = restapi_object.contract.id
#  optional, does not need to be configured in most cases

provider "restapi" {
  uri                  = "https://api.ionos.com/reseller/v2"
  write_returns_object = true
  headers = {
    Authorization = "Basic ${var.token}"
    Content-Type  = "application/json"
  }
  create_method  = "POST"
  update_method  = "UPDATE"
  destroy_method = "DELETE"
}

terraform {
  backend "s3" {
    bucket = "buildingblocks-tfstates-p32kj" # Must match what's configured in automation backend
    key    = "terraform/ionos-contracts"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/LikvidBuildingBlockServiceRole" # Must match what's configured in automation backend
  }
}
