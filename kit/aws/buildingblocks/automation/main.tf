# user referenced in building block definition
resource "aws_iam_user" "user" {
  provider = aws.tf-backend
  name     = "${var.foundation}-${var.building_block_backend_account_service_user_name}"
}

resource "aws_iam_access_key" "users_access_key" {
  provider = aws.tf-backend
  user     = aws_iam_user.user.name
}

# access terraform states in s3 bucket
resource "aws_iam_user_policy" "bucket_access" {
  provider = aws.tf-backend
  name     = "access-s3-bucket-access"
  user     = aws_iam_user.user.name

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
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      }
    ]
  })
}

data "aws_partition" "current" {}

# access building block service role in target accounts
data "aws_iam_policy_document" "building_block_service" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:${data.aws_partition.current.partition}:iam::*:role/${var.building_block_target_account_access_role_name}"]
  }
}

resource "aws_iam_user_policy" "assume_roles" {
  provider = aws.tf-backend
  name     = "assume-roles"
  user     = aws_iam_user.user.name
  policy   = data.aws_iam_policy_document.building_block_service.json
}
