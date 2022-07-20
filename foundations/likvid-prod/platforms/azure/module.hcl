# define shared configuration here that most non-bootstrap modules in this platform want to include

# optional: make collie's platform config available in terragrunt by parsing frontmatter
locals {
  platform = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])
}

# optional: reference the bootstrap module to access its outputs
dependency "bootstrap" {
  config_path = "${path_relative_from_include()}/bootstrap"
}

# recommended: generate a default provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "todo" {
  # tip: you can access collie configuration from the local above, e.g. "${local.platform.azure.aadTenantId}"
  # tip: you can access bootstrap module output like secrets from the dependency above, e.g. "${dependency.bootstrap.outputs.client_secret}"
}
EOF
}
