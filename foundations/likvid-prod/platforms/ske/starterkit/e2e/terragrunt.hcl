dependency "deployment" {
  config_path = "../"
}

# Hub coordinates: single source of truth in the sibling deployment's hub.hcl.
include "hub" {
  path   = "../hub.hcl"
  expose = true
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}/e2e?ref=${include.hub.locals.git_ref}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

# `tofu test` does not type-decode complex TF_VAR_* env vars — use auto.tfvars.json so the
# structured `test_context` variable arrives correctly typed in test assertion scope.
#
# Foundation mode: the deployment (`../`) already created the BBD, so we set `bbd_version_ref` to
# order an ephemeral building block against it. That also means none of the build-from-source
# fixtures (forgejo, DNS zone) or backplane secrets are passed — the e2e module builds no backplane
# here. See the meshstack-hub `e2e-test` skill for the invocation protocol.
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
