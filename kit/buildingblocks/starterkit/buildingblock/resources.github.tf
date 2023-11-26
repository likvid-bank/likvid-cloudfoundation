# note: this building block is expected to be executed with a config.tf file as output by the "backplane" module in the
# parent dir, this needs to provided in the BB execution enviornment

resource "github_repository" "repository" {
  name        = var.repo_name
  description = "Created from a Likvid Bank DevOps Toolchain starter kit for ${var.workspace_identifier}.${var.project_identifier}"
  visibility  = "private"

  topics = [ "starterkit" ]

  auto_init            = true
  vulnerability_alerts = true

  lifecycle {
    ignore_changes = [description]
  }
  
  template {
    owner      = var.template_owner
    repository = var.template_repo
  }
}

# In theory these settings could also be copied from the template repository, however it's unclear whether this is
# supported for every setting we care about. Having them in the BB instead of the backplane has the following benefits
# - we can decide to upgrade these rules on existing repos with a BB definition version upgrade
# - we have important concepts like the sandbox environment available for cross-referencing in other resources and don't
#   need "magic constants" here

resource "github_repository_environment" "sandbox" {
  environment = "sandbox"
  repository  = github_repository.repository.name

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "sandbox" {
  repository     = github_repository.repository.name
  environment    = github_repository_environment.sandbox.environment
  branch_pattern = "main"
}