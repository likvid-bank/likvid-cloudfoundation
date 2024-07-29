terraform {
  backend "s3" {
    bucket = "likvid.bb-tf-backend" # Must match what's configured in automation backend
    key    = "terraform/buildingblock-backplane/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/LikvidMeshfedService-MeshstackAccountAccessRole"
  }
}

