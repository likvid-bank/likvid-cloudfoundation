variable "meshstack_api" {
  description = "API user with access to meshStack"
  default     = null
  type = object({
    endpoint = string,
    username = string,
    password = string
  })
}

variable "meshpanel_base_url" {
  description = "Base URL of the meshPanel"
  default     = null
  type        = string
}


variable "static_website_assets_demo" {
  description = "Configuration for the static website assets demos"
  nullable    = false
  sensitive   = true
  type = object({
    repository            = string,
    api_key_id            = string,
    api_key_secret        = string
    aws_sso_instance_arn  = string,
    aws_identity_store_id = string,
    gha_aws_role_to_assume= string
  })
}