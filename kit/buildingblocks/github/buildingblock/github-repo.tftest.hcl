# terraform test is cool because it does the apply and destroy lifecycle
# what it doesn't test though is the backend storage. if we want to test that, we need to that via terragrunt

run "verify" {
  variables {
    repository_name = "integrationtest"
    private         = true
    has_issues      = true
  }

  assert {
    condition     = output.repository_name == "integrationtest"
    error_message = "did not produce the correct repository_name output"
  }

  assert {
    condition     = output.private == true
    error_message = "Repository should be private"
  }

  assert {
    condition     = output.has_issues == true
    error_message = "Issues should be enabled for the repository"
  }
}
