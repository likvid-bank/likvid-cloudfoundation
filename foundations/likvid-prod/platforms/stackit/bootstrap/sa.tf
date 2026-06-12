

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
      item     = "aud"
      operator = "equals"
      value    = "sts.accounts.stackit.cloud" # the default aud requested by the stackit terraform provider
    },
    {
      item     = "sub"
      operator = "equals"
      value    = "repo:likvid-bank/likvid-cloudfoundation:environment:likvid-prod"
    }
  ]
}