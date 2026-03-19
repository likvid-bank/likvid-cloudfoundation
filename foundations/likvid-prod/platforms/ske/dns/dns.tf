variable "dns_name" {
  type = string
}

variable "stackit_project_id" {
  type = string
}

variable "haproxy_lb_ip" {
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

resource "stackit_dns_record_set" "A" {
  project_id = var.stackit_project_id
  zone_id    = stackit_dns_zone.this.zone_id
  name       = "*.${var.dns_name}.stackit.run"
  type       = "A"
  records    = [var.haproxy_lb_ip]
  comment    = "Wildcard app routing to HAProxy ingress load balancer"
}

moved {
  from = stackit_dns_zone.idp
  to   = stackit_dns_zone.this
}

output "zone_name" {
  value = stackit_dns_zone.this.dns_name
}
