include "platform" {
    path = find_in_parent_folders("platform.hcl")
    expose = true
  }

include "module" {
    path = find_in_parent_folders("module.hcl")
  }

terraform {
    source = "${get_repo_root()}//kit/alz/base"
  }

inputs = {
    
  root_parent_id = "likvid-prod"
  root_id        = "alz"
  root_name      = "alz"
  default_location = "germanywestcentral"
  deploy_corp_landing_zones = true
  deploy_online_landing_zones = true
  # Management resources
  deploy_management_resources = true
  subscription_id_management  = "${include.platform.locals.platform.azure.subscriptionId}" # Subscription created manually as a prerequisite

  }