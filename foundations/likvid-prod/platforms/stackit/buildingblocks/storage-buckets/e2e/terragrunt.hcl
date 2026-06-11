dependency "deployment" {
  config_path = "../"
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${dependency.deployment.outputs.e2e.hub.module}/e2e?ref=${dependency.deployment.outputs.e2e.hub.git_ref}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

generate "versions_override" {
  path      = "versions_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.21.0"
    }
  }
}
EOF
}

# `tofu test` does not type-decode complex TF_VAR_* env vars — use auto.tfvars.json so
# structured variables like test_context arrive correctly typed in test assertion scope.
generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    bbd_version_ref             = dependency.deployment.outputs.e2e.building_block_definition.version_ref
    # todo: this hardcoding is probably not ideal and will break in CI - we're not there yet though so this can be fixed later
    stackit_service_account_key = file("~/.stackit/credentials.json")
    test_context = {
      workspace   = dependency.deployment.outputs.e2e.owning_workspace
      name_suffix = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")
    }
  })
}
