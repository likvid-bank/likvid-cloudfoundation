variable "dns_name" {
  type = string
}


resource "stackit_dns_zone" "this" {
  project_id    = var.stackit_project_id
  name          = "${var.dns_name}-ske-starterkit"
  dns_name      = "${var.dns_name}.stackit.run"
  contact_email = "support@meshcloud.io"
  type          = "primary"
  default_ttl   = 300
}

moved {
  from = stackit_dns_zone.idp
  to   = stackit_dns_zone.this
}

output "dns_zone_id" {
  value = stackit_dns_zone.this.zone_id
}
