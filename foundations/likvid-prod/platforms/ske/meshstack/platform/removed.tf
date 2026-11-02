removed {
  from = meshstack_platform.this
  lifecycle {
    destroy = false
  }
}

removed {
  from = meshstack_landingzone.this
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.meshplatform
  lifecycle {
    destroy = false
  }
}
