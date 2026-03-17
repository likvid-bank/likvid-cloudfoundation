variable "output_dir" {
  type        = string
  description = "Absolute path to the demo-runbook source directory (set by Terragrunt via get_terragrunt_dir)"
}

variable "payer_account_id" {
  type        = string
  description = "AWS payer / management account ID"
}

# --- organization ---

variable "org_id" {
  type        = string
  description = "AWS Organizations organization ID"
}

variable "org_root_id" {
  type        = string
  description = "ID of the organization root"
}

variable "parent_ou_id" {
  type        = string
  description = "ID of the parent (likvid) OU"
}

variable "landingzones_ou_id" {
  type        = string
  description = "ID of the likvid-landingzones OU"
}

variable "management_account_id" {
  type        = string
  description = "ID of the management account (audit/TF backend)"
}

variable "networking_account_id" {
  type        = string
  description = "ID of the networking account"
}

variable "automation_account_id" {
  type        = string
  description = "ID of the automation account"
}

variable "meshstack_account_id" {
  type        = string
  description = "ID of the meshStack account"
}

# --- landing zones ---

variable "cloud_native_ou_id" {
  type        = string
  description = "ID of the cloud-native OU"
}

variable "cloud_native_dev_ou_id" {
  type        = string
  description = "ID of the cloud-native dev OU"
}

variable "cloud_native_prod_ou_id" {
  type        = string
  description = "ID of the cloud-native prod OU"
}

variable "on_prem_dev_ou_id" {
  type        = string
  description = "ID of the on-prem dev OU"
}

variable "on_prem_prod_ou_id" {
  type        = string
  description = "ID of the on-prem prod OU"
}

variable "bedrock_ou_id" {
  type        = string
  description = "ID of the bedrock OU"
}

variable "m25_platform_ou_id" {
  type        = string
  description = "ID of the M25 platform OU"
}

# --- organization-trail ---

variable "org_trail_arn" {
  type        = string
  description = "ARN of the organization CloudTrail trail"
}

variable "trail_s3_bucket" {
  type        = string
  description = "Name of the CloudTrail S3 audit bucket"
}
