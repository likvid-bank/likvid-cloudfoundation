resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "terraform_state" {
  provider = aws.tf-backend
  bucket   = "buildingblocks-tfstates-${random_string.resource_code.result}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  provider = aws.tf-backend
  bucket   = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  provider     = aws.tf-backend
  name         = "buildingblocks-tfstates"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
