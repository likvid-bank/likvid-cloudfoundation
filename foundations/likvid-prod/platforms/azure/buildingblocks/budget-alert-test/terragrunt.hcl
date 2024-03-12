# this is a test for a meshStack building block
# hence it's using config.tf, and not collie-style composition (maybe we should align the two and let collie use config_tf style as well)
dependency "buildingblock" {
  config_path = "../budget-alert"
}

dependency "glaskugel" {
  config_path = "../../tenants/glaskugel"
}

generate "config" {
  path      = "config.tf"
  if_exists = "overwrite"
  contents  = dependency.buildingblock.outputs.config_tf
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/budget-alert/buildingblock"
}

inputs = {
  subscription_id = dependency.glaskugel.outputs.subscription_id
  contact_emails = "foo@example.com, bar@example.com"
}