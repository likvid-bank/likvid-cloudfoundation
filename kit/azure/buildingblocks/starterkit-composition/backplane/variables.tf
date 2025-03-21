variable "application_name" {
  type     = string
  nullable = false
}

variable "tfstates_resource_manager_id" {
  type     = string
  nullable = false
}

variable "tfstates_resource_group_name" {
  type     = string
  nullable = false
}

variable "tfstates_storage_account_name" {
  type     = string
  nullable = false
}

variable "tfstates_storage_container_name" {
  type     = string
  nullable = false
}


variable "location" {
  type        = string
  nullable    = false
  description = "Azure location for deploying the building block terraform state storage account"
}

variable "scope" {
  type        = string
  nullable    = false
  description = "Scope where the building block should be deployable, typically a Sandbox Landing Zone Management Group"
}

# unfortunately we can't set up the app via terraform right now, so we need to manually set this up
# outside of terraform an inject result as vars

variable "github_app_id" {
  type        = number
  description = "id of your GitHub App"
}

variable "github_app_installation_id" {
  type        = number
  description = "id of your GitHub App installation as it appears in URLs on GitHub.com"
}

variable "github_org" {
  type        = string
  description = "id of your GitHub organization as it appears in URLs on GitHub.com"
}
