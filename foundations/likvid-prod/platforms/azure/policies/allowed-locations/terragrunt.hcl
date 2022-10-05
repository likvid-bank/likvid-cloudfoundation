include "platform" {
  path = find_in_parent_folders("platform.hcl") 
  expose = true
}

include "module" {
  path = find_in_parent_folders("module.hcl")
}

terraform {
  source = "${get_repo_root()}//kit/azure/policy/allowed-locations"
}

inputs = {
  allowed_locations = [
  "germanywestcentral", 
  "germany"
  ]
  subscription_id = include.platform.locals.platform.azure.subscriptionId
  parent_mg_id = include.platform.locals.platform.azure.aadTenantId
}