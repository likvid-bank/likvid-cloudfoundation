output "bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "bucket_id" {
  value = aws_s3_bucket.terraform_state.id
}

output "bucket_region" {
  value = aws_s3_bucket.terraform_state.region
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "aws_iam_access_key" {
  value     = aws_iam_access_key.users_access_key.secret
  sensitive = true
}

output "aws_iam_access_id" {
  value = aws_iam_access_key.users_access_key.id
}

output "aws_iam_user" {
  value = aws_iam_user.user.arn
}
