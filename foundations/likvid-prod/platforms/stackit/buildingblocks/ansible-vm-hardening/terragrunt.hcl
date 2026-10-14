include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

# Hub coordinates live in hub.hcl (single source of truth, shared with a future e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "server" {
  config_path = "../server"
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

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}?ref=${include.hub.locals.git_ref}"
}

inputs = {
  hub = {
    git_ref   = include.hub.locals.git_ref
    bbd_draft = include.hub.locals.bbd_draft
  }

  meshstack = {
    # Meant for m25-platform, the team offering the hardening service. It sits in stackit-platform for
    # now because it depends on the STACKIT Server definition, whose version is still a draft and so
    # visible to its owner only. Move it once the server version is released and a dependency across
    # workspaces is confirmed to work. Moving means a new definition: blocks ordered from this one
    # have to be ordered again.
    owning_workspace_identifier = "stackit-platform"

    # The building block tag the landing zone puts on the definitions it registers, so the policy
    # "Enforce Landing Zone Family clearance" offers this one on the same tenants.
    tags = { LandingZoneClearance = ["cloud-native"] }
  }

  # Hardening attaches to the VMs the STACKIT Server definition provisions.
  vm_bbd_uuid              = dependency.server.outputs.building_block_definition.uuid
  supported_platform_types = ["STACKIT"]

  # A demo: one pasted snippet opens the landing page. Everyone who can see the hardening block in
  # meshPanel can read the VM's key; the GitHub repository never shows it.
  summary_embeds_ssh_key = true

  github_repository = "likvid-bank/ansible"

  # "GitHub (likvid-bank organization)" in the admin workspace likvid-cloud, so meshStack holds one
  # copy of the app key, not one per definition.
  github_integration_uuid = "ad1547a3-5ce6-11f0-a63c-b2e246c431d1"

  # The backplane still commits the workflow and the playbook with the app. CI provides its key as
  # GITHUB_APP_PEM_FILE; locally, export it from Vault before running this unit.
  github_app_id              = "654209"
  github_app_installation_id = "44437049"
  github_app_private_key     = get_env("GITHUB_APP_PEM_FILE")
}
