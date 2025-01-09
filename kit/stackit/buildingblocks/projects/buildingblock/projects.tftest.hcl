run "verify" {
  variables {

    aws_account_id      = "490004649140"
    parent_container_id = "0a4006f8-eaf3-417c-b2fa-7e9c08ebffba"
    workspace_id        = "stackit"
    project_id          = "test"
    users = [
      {
        meshIdentifier = "identifier0"
        username       = "likvid-daniela@meshcloud.io"
        firstName      = "likvid"
        lastName       = "daniela"
        email          = "likvid-daniela@meshcloud.io"
        euid           = "likvid-daniela@meshcloud.io"
        roles          = ["reader"]
      },
      {
        meshIdentifier = "identifier1"
        username       = "likvid-tom@meshcloud.io"
        firstName      = "likvid"
        lastName       = "tom"
        email          = "likvid-tom@meshcloud.io"
        euid           = "likvid-tom@meshcloud.io"
        roles          = ["user"]
      },
      {
        meshIdentifier = "identifier1"
        username       = "likvid-anna@meshcloud.io"
        firstName      = "likvid"
        lastName       = "anna"
        email          = "likvid-anna@meshcloud.io"
        euid           = "likvid-anna@meshcloud.io"
        roles          = ["admin"]
      }
    ]
  }

  assert {
    condition     = length(var.users) > 0
    error_message = "No users provided"
  }
}
