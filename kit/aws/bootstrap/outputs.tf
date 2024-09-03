output "aws_root_account_id" {
  value       = var.aws_root_account_id
  description = "The id of your AWS Organization's root account"
}

output "validation_iam_role_arn" {
  value       = aws_iam_role.validation.arn
  description = "ARN of the IAM role that github can assume to validate the cloudfoundation deployment"
}