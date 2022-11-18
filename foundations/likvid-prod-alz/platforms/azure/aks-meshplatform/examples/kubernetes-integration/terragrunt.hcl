include "platform" {
    path = find_in_parent_folders("platform.hcl")
  }

include "module" {
    path = find_in_parent_folders("module.hcl")
  }

terraform {
    source = "${get_repo_root()}//kit/alz/aks-meshplatform/examples/kubernetes-integration"
  }

inputs = {
    # todo: specify inputs to terraform module
  }