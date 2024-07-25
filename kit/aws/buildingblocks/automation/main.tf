resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.foundation_name}.bb-tf-backend"
  force_destroy = true
}

resource "aws_iam_user" "user" {
  name = "buildingblock-cf-deploy"
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
          "*"
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
