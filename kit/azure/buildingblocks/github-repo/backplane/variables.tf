variable "key_vault" {
  type = object({
    name                = string
    resource_group_name = string
  })
  description = "Key Vault configuration"
}

variable "github_token_secret_name" {
  type        = string
  description = "Name of the secret in Key Vault that holds the GitHub token"
}
