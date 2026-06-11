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

# `tofu test` does not type-decode complex TF_VAR_* env vars — use auto.tfvars.json so the
# structured `test_context` variable arrives correctly typed in test assertion scope.
#
# Foundation mode: the deployment (`../`) already created the BBD, so we set `bbd_version_ref` to
# order an ephemeral building block against it. Setting `bbd_version_ref` (and omitting `fixtures`)
# selects foundation mode; the e2e module rejects setting both. See the meshstack-hub `e2e-test`
# skill for the invocation protocol.
generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      workspace       = dependency.deployment.outputs.e2e.owning_workspace
      name_suffix     = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")
      hub_git_ref     = dependency.deployment.outputs.e2e.hub.git_ref
      bbd_version_ref = { uuid = dependency.deployment.outputs.e2e.building_block_definition.version_ref.uuid }
    }
  })
}
