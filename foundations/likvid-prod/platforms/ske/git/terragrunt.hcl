include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOT
provider "stackit" {
  default_region        = "eu01"
  service_account_key   = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
  enable_beta_resources = true
}

provider "restapi" {
  uri = "https://likvid.git.onstackit.cloud"
}
EOT
}
