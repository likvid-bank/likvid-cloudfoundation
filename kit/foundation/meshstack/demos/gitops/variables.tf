variable "repository" {
  description = "The repository for static website assets demos"
  type        = string
  nullable    = false
}

variable "meshstack_api_key_id" {
  description = "API key ID for static website assets demos"
  type        = string
  nullable    = false
}

variable "meshstack_api_key_secret" {
  description = "API key secret for static website assets demos"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID hosting the s3 buckets provisioned in static website assets demos"
  type        = string
  nullable    = false

}
variable "aws_sso_instance_arn" {
  description = "AWS SSO instance ARN"
  type        = string
  nullable    = false
}

variable "aws_identity_store_id" {
  description = "AWS identity store ID"
  type        = string
  nullable    = false
}

variable "gha_aws_role_to_assume" {
  description = "GitHub Actions AWS role to assume"
  type        = string
  nullable    = false
}

variable "documentation_vars" {
  description = "Template for the static website assets demo"
  type = object({
    md_workspace_m25_platform_team : string,
    md_workspace_m25_online_banking : string,
  })
  nullable = false
}