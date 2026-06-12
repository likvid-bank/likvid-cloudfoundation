

# Service Account
# make the service account owner of the smoke test fixture project

resource "stackit_service_account" "sa" {
  name       = "likvid-cfn-ci"
  project_id = stackit_resourcemanager_project.management.project_id
}

resource "stackit_authorization_project_role_assignment" "sa" {
  resource_id = stackit_resourcemanager_project.management.project_id
  role        = "owner"
  subject     = stackit_service_account.sa.email
}


## allow WIF from github actions for ci/cd execution

resource "stackit_service_account_federated_identity_provider" "provider" {
  project_id            = stackit_service_account.sa.project_id
  service_account_email = stackit_service_account.sa.email
  name                  = "github-actions"
  issuer                = "https://token.actions.githubusercontent.com"

  assertions = [
    {
      item     = "aud" # Including the audience check is mandatory for security reasons, the value is free to choose
      operator = "equals"
      value    = "sts.accounts.stackit.cloud"
      # i'm not sure this is correct, given that https://docs.github.com/en/actions/reference/security/oidc#standard-audience-issuer-and-subject-claims lists 
      # > By default, this is the URL of the repository owner
      # and i don't see how/if the terraform provider calls getIdToken somehow with a custom audience
    },
    {
      item     = "sub"
      operator = "equals"
      value    = "repo:likvid-bank/likvid-cloudfoundation:environment:likvid-prod"
    }
  ]
}