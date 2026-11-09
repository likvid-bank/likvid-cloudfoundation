# Foundation-mode smoke test — see the `hub` skill for the protocol.

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

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/ske/ske-starterkit/e2e?ref=${include.hub.locals.git_ref}"
}

generate "smoke_tfvars" {
  path              = "smoke.auto.tfvars.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = jsonencode({
    test_context = {
      mode      = "foundation"
      workspace = include.smoke.locals.meshstack.workspace
      # The platform building block publishes the starterkit definitions in its own workspace.
      definition_workspace      = "devops-platform"
      bbd_draft                 = include.hub.locals.bbd_draft
      run_id                    = include.smoke_run.locals.run_id
      payment_method_identifier = "devops-platform-budget"
    }
  })
}
