output "org_trail_arn" {
  value = aws_cloudtrail.organization.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.cloudtrail.bucket
}
