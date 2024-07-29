variable "bucket_name" {
  description = "Name of the S3 bucket"
}

variable "building_block_backend_account_service_user_name" {
  type        = string
  description = "Name of the building-block-service user."
}

variable "building_block_backend_account_id" {
  type        = string
  description = "The ID of the meshcloud AWS Account"
}

variable "building_block_target_account_access_role_name" {
  type        = string
  default     = "BuildingBlockAccessRole"
  description = "Account access role used by building-block-service."
}
