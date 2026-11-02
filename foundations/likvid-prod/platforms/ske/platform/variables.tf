variable "hub_ref" {
  type = string
}

variable "forgejo_api_token" {
  type      = string
  sensitive = true
}
