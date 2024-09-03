variable "meshstack_api" {
  description = "API user with access to meshStack"
  default     = null
  type = object({
    endpoint = string,
    username = string,
    password = string
  })
}
