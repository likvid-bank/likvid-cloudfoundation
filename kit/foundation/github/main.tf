
data "github_repository" "foundation_repo" {
  name = var.github_repo

  lifecycle {
    postcondition {
      condition     = self.name != null
      error_message = <<EOF
        The github provider returns null when the foundation repo is inaccessible.
        This usually indicates there's something wrong with your github authentication.
      EOF
    }
  }
}

resource "github_repository_environment" "env" {
  environment = var.foundation
  repository  = data.github_repository.foundation_repo.name
}

resource "github_actions_environment_variable" "variables" {
  for_each = var.actions_variables

  repository    = data.github_repository.foundation_repo.name
  environment   = github_repository_environment.env.environment
  variable_name = each.key
  value         = each.value
}