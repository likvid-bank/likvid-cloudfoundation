# variable "building_block_backend_bucket_name" {
#   description = "Name of the S3 bucket"
# }

variable "foundation" {
  type        = string
  description = "Name of your Cloud Foundation configuration"
}

variable "building_block_backend_account_service_user_name" {
  type        = string
  description = "Name of the IAM user that meshStack will use to manage building block resources"
}

variable "building_block_backend_account_id" {
  type        = string
  description = "The ID of the backend AWS Account"
}

variable "building_block_target_ou_ids" {
  type        = set(string)
  description = "List of OUs to deploy the building block service role to"
}

variable "building_block_target_account_access_role_name" {
  type        = string
  default     = "BuildingBlockServiceRole"
  description = "Account access role used by building-block-service."
}
