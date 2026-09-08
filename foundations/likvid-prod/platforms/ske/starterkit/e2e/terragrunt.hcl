# Foundation-mode smoke test — see the `hub` skill for the protocol.

include "smoke" {
  path   = find_in_parent_folders("smoke.hcl")
  expose = true
}

include "hub" {
  path   = "../hub.hcl"
  expose = true
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}/e2e?ref=${include.hub.locals.git_ref}"
}

generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode        = "foundation"
      workspace   = include.smoke.locals.meshstack.workspace
      bbd_draft   = include.hub.locals.bbd_draft
      name_suffix = run_cmd("--terragrunt-quiet", "date", "-u", "+%Y%m%d%H%M%S")
    }
  })
}
