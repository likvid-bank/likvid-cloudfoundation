include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/ionos/bootstrap"
}

inputs = {
  email     = "collie@meshcloud.io"
  firstname = "Collie"
  lastname  = "CLI"
}
