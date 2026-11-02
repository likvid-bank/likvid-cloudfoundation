removed {
  from = stackit_git.git
  lifecycle {
    destroy = false
  }
}

removed {
  from = restapi_object.forgejo_organization
  lifecycle {
    destroy = false
  }
}
