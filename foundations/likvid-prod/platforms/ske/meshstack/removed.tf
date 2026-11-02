removed {
  from = meshstack_project.this
  lifecycle {
    destroy = false
  }
}

removed {
  from = meshstack_tenant.this
  lifecycle {
    destroy = false
  }
}
