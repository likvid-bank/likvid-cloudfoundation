removed {
  from = module.starterkit
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.git_repository
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.forgejo_connector
  lifecycle {
    destroy = false
  }
}
