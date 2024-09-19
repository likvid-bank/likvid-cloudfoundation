
data "github_repository" "cloudfoundation" {
  name = var.github_repo

  lifecycle {
    postcondition {
      condition     = self.name != null
      error_message = <<EOF
        The github provider returns null when the repo is inaccessible.
        This usually indicates there's something wrong with your github authentication.
      EOF
    }
  }
}

# todo: we have to think about how we separate meshcloud-dev and meshcloud-prod here, as there will be two
# different service accounts for each
resource "github_repository_environment" "env" {
  environment = var.foundation
  repository  = data.github_repository.cloudfoundation.name
}

resource "github_actions_environment_variable" "variables" {
  for_each = var.actions_variables

  repository    = data.github_repository.cloudfoundation.name
  environment   = github_repository_environment.env.environment
  variable_name = each.key
  value         = each.value
}
