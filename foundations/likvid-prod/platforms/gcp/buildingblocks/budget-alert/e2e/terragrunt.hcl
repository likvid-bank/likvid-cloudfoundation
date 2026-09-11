# Foundation-mode smoke test — see the `hub` skill for the protocol.
#
# The definition itself is looked up through the meshStack API, so the only credential this run
# needs is the meshStack API key `smoke.hcl` configures. The deployment is still a `dependency`
# because a tenant-level building block is ordered against a meshTenant uuid, and only the
# deployment resolves that.

include "smoke" {
  path   = find_in_parent_folders("smoke.hcl")
  expose = true
}

include "hub" {
  path   = "../hub.hcl"
  expose = true
}

include "smoke_run" {
  path   = find_in_parent_folders("smoke_run.hcl")
  expose = true
}

dependency "deployment" {
  config_path = "../"
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}/e2e?ref=${include.hub.locals.git_ref}"
}

# `tofu test` does not type-decode complex TF_VAR_* env vars, so the structured `test_context`
# arrives as an auto-loaded var-file instead.
generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode      = "foundation"
      workspace = include.smoke.locals.meshstack.workspace
      bbd_draft = include.hub.locals.bbd_draft
      run_id    = include.smoke_run.locals.run_id
      fixtures  = dependency.deployment.outputs.e2e.fixtures
    }
  })
}
