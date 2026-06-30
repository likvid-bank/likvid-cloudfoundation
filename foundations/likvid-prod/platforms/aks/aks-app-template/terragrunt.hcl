include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# Requires GITHUB_APP_PEM_FILE env var (same as the starterkit module).
# id and installation_id are hardcoded as they are not sensitive.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "likvid-bank"
  app_auth {
    id              = "654209"
    installation_id = "44437049"
  }
}
EOF
}
