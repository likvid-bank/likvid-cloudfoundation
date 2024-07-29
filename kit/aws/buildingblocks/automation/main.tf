# terragrunt bootstraps and manages our buvcket, so we only reference it here for generating outputs
data "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}

resource "aws_iam_user" "user" {
  name = var.building_block_backend_account_service_user_name
}

resource "aws_iam_access_key" "users_access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "bucket_access" {
  name = "access-s3-bucket-access"
  user = aws_iam_user.user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
        ],
        "Resource" : [
          "*" #TODO Scope to bucket
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy" "assume_roles" {
  name = "assume-roles"
  user = aws_iam_user.user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "*"
      }
    ]
  })
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "building_block_service" {
  version = "2012-10-17"
  statement {
    sid       = "StsAccessMemberAccount"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:${data.aws_partition.current.partition}:iam::*:role/${var.building_block_target_account_access_role_name}"]
  }
}

