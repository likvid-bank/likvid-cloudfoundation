include "platform" {
    path = find_in_parent_folders("platform.hcl")
    expose = true
  }

include "module" {
    path = find_in_parent_folders("module.hcl")
  }

terraform {
    source = "${get_repo_root()}//kit/azure/aks-meshplatform/examples/basic-aks-integration"
  }


inputs = {
    subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
    aad_group_id = "9fdf3001-e8ad-445d-93a8-e3e06c4f3b3c"
  }