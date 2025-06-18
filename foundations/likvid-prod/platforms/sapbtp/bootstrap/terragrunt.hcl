include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# exclude bootstrap module for all operations when run in a stack
# bootstrap modules must be run individually via `terragrunt apply`
exclude {
  if      = true
  actions = ["all"]
}

terraform {
  source = "${get_repo_root()}//kit/sapbtp/bootstrap"
}

inputs = {
  email     = "collie@meshcloud.io"
  firstname = "Collie"
  lastname  = "CLI"
}
