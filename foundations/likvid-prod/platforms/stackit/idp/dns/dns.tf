resource "stackit_dns_zone" "idp" {
  project_id    = var.stackit_project_id
  name          = "starterkit"
  dns_name      = "try-meshstack.stackit.run"
  contact_email = "ske@meshcloud.io"
  type          = "primary"
  default_ttl   = 300
}
