terraform {
  backend "s3" {
    bucket = "buildingblocks-tfstates-yawi2"# Must match what's configured in automation backend
    key    = "terraform/iam-user"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/LikvidBuildingBlockServiceRole" # Must match what's configured in automation backend
  }
}

