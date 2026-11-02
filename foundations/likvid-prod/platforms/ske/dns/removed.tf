removed {
  from = stackit_dns_zone.this
  lifecycle {
    destroy = false
  }
}

removed {
  from = stackit_dns_record_set.A
  lifecycle {
    destroy = false
  }
}
