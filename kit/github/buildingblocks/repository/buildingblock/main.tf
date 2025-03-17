resource "github_repository" "repository" {
  name                 = var.repo_name
  description          = var.repo_description
  visibility           = var.repo_visibility
  auto_init            = false
  vulnerability_alerts = true
  archive_on_destroy   = true

  template {
    owner                = "likvid-bank"
    repository           = "meta-marketplace"
    include_all_branches = true
  }
}
