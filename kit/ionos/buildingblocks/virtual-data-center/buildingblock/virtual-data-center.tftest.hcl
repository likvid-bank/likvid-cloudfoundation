
run "verify" {
  variables {

    aws_account_id = "490004649140"
    contract_id    = "34858204"
    workspace_id   = "ionos"
    project_id     = "testvdc"
    users = [
      {
        meshIdentifier = "identifier1"
        username       = "likvid-tom@meshcloud.io"
        firstName      = "likvid"
        lastName       = "tom"
        email          = "likvid-tom@meshcloud.io"
        euid           = "likvid-tom@meshcloud.io"
        roles          = ["user"]
      }
    ]
  }

  assert {
    condition     = length(var.users) > 0
    error_message = "No users provided"
  }
}
