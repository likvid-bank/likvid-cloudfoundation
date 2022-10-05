include "platform" {
  path = find_in_parent_folders("platform.hcl") 
  expose = true
}

include "module" {
  path = find_in_parent_folders("module.hcl")
}

terraform {
  source = "${get_repo_root()}//kit/azure/admin/organization-hierarchy"
}

inputs = {
  aad_tenant_id = include.platform.locals.platform.azure.aadTenantId
  platform_management_group_name = "festo"
  allowed_locations = [
    "germanywestcentral",
  ]
}