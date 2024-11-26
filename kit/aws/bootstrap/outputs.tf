output "management_account_id" {
  value       = var.management_account_id
  description = "The id of your AWS Organization's root account"
}

output "validation_iam_role_arn" {
  value       = aws_iam_role.validation.arn
  description = "ARN of the IAM role that github can assume to validate the cloudfoundation deployment"
}

output "tf_backend_account_id" {
  value       = var.tf_backend_account_id
  description = "The id of the management account"
}

output "networking_account_id" {
  value = var.networking_account_id
  description = "The id of the networking account"
}
