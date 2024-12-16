include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

include "module" {
  path = find_in_parent_folders("module.hcl")
}

terraform {
  source = "${get_repo_root()}//kit/ionos/admin/users"
}

inputs = {
  users = [
    { email = "fnowarre@meshcloud.io", firstname = "Florian", lastname = "Nowarre" },

  ]
  api_users = [
    { email = "apiuser@likvid.io", firstname = "Api", lastname = "User" }
  ]
}
