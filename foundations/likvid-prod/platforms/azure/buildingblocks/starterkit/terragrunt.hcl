include "platform" {
  path = find_in_parent_folders("platform.hcl")
  expose = true
}

# note: the subscription hosting the buildingblock backplane is managed via meshStack in
#   Workspace: DevOps Toolchain
#   Project: buildingblocks-prod
# azurerm therefore uses local Azure CLI user authentication

# todo: not quite sure how this will interact with our ability to generate docs in CI/CD for this module
# it _should_ be fine since we only need to read terraform state

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "likvid-bank"
}

provider "azuread" {
  tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
}

provider "azurerm" {
  features {}
  skip_provider_registration = false
  subscription_id = "76a68a1d-674b-401b-976a-8b251d535f8c"
}

EOF
}

terraform {
  source = "${get_repo_root()}//kit/buildingblocks/starterkit"
}

inputs = {
  service_principal_name = "devops-toolchain-starterkit" 
  location = "germanywestcentral"
  
}