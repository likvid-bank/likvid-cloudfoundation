include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/ionos/bootstrap"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "ionoscloud" {
  contract_number = "34858204"
}
EOF
}

inputs = {
  admin = [
    { email = "likvid-api@meshcloud.io", firstname = "likvid", lastname = "bank" }
  ]
  users = [
    #{ email = "bschoor@meshcloud.io", firstname = "Ben", lastname = "Schoor" },
    { email = "likvid-daniela@meshcloud.io", firstname = "Likvid", lastname = "Daniela" },
    { email = "likvid-tom@meshcloud.io", firstname = "Likvid", lastname = "Tom" },
    #{ email = "likvid-anna@meshcloud.io", firstname = "Anna", lastname = "Admin" },
    # outcommented because IONOS takes time when users are deleted until a recreation is possible
    { email = "fnowarre@meshcloud.io", firstname = "Florian", lastname = "Nowarre" },
    { email = "ckraus@meshcloud.io", firstname = "Christina", lastname = "Kraus" }
  ]
}
