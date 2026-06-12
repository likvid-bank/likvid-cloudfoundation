dependency "deployment" {
  config_path = "../"
}

locals {
  # Hub coordinates are read from deployment outputs at generate-time (not in terraform.source).
  # terraform.source must be a static expression because Terragrunt evaluates it during
  # `--all` module discovery before dependency outputs are available, causing an
  # "Unsuitable value: value must be known" error.
  # Keep this ref in sync with local.hub.git_ref in the sibling main.tf.
  hub_module  = "stackit/storage-bucket"
  hub_git_ref = "44e21d6830aa7c6a23c2579506b4b61bf4aa69be"

  # In CI: STACKIT_FEDERATED_TOKEN_FILE is set by the workflow (GitHub OIDC token written to a
  # temp file). Use WIF with the CI service account. Locally: no token file → fall back to the
  # provider default, which reads STACKIT_SERVICE_ACCOUNT_KEY_PATH from setup-env.sh.
  _use_wif = get_env("STACKIT_FEDERATED_TOKEN_FILE", "") != ""

  stackit_provider_override_contents = local._use_wif ? join("\n", [
    "provider \"stackit\" {",
    "  service_account_email = \"${get_env("STACKIT_SERVICE_ACCOUNT_EMAIL")}\"",
    "  use_oidc              = true",
    "  experiments           = [\"iam\"]",
    "}",
  ]) : join("\n", [
    "provider \"stackit\" {",
    "  experiments = [\"iam\"]",
    "}",
  ])
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${local.hub_module}/e2e?ref=${local.hub_git_ref}"
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

generate "stackit_provider_override" {
  path      = "stackit_provider_override.tf"
  if_exists = "overwrite"
  contents  = local.stackit_provider_override_contents
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
