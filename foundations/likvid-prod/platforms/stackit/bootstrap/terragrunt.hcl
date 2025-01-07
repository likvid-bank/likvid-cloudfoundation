include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/stackit/bootstrap"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  region              = "eu01"
  service_account_token = "${get_env("STACKIT_SERVICE_ACCOUNT_TOKEN")}"
}
EOF
}

inputs = {
  admin = [
    { subject = "fnowarre@meshcloud.io" },
    { subject = "jrudolph@meshcloud.io" },
    { subject = "malhussan@meshcloud.io" }
  ]
  users = [
    { email = "bschoor@meshcloud.io" },
    { email = "ckraus@meshcloud.io" }
  ]
}
