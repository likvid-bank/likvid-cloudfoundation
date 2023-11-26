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
