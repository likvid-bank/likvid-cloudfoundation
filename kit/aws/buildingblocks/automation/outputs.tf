output "bucket_arn" {
  value = data.aws_s3_bucket.s3_bucket.arn
}

output "bucket_id" {
  value = data.aws_s3_bucket.s3_bucket.id
}

output "bucket_region" {
  value = data.aws_s3_bucket.s3_bucket.region
}

output "bucket_name" {
  value = data.aws_s3_bucket.s3_bucket.bucket
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
