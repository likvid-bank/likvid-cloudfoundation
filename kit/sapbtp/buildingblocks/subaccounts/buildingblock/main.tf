resource "btp_subaccount" "subaccount" {
  name      = "sa-${var.workspace}-${var.project}"
  subdomain = "sd-${var.workspace}-${var.project}"
  parent_id = var.parent_id
  region    = var.region
}
