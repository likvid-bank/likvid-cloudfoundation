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