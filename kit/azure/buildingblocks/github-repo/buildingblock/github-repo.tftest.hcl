# terraform test is cool because it does the apply and destroy lifecycle
# what it doesn't test though is the backend storage. if we want to test that, we need to that via terragrunt

run "verify" {
  variables {
    private = true
  }

  assert {
    condition     = output.repo_name == "likvid-github-repo-test"
    error_message = "did not produce the correct repository_name output"
  }
}
