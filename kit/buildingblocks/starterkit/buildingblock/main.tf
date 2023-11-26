# note: this building block is expected to be executed with a config.tf file as output by the "backplane" module in the
# parent dir, this needs to provided in the BB execution enviornment

resource "github_repository" "repository" {
  name        = var.repo_name
  description = var.description
  visibility  = "private"

  auto_init            = true
  vulnerability_alerts = true

  template {
    owner                = var.template_owner
    repository           = var.template_repo   
  }
}
