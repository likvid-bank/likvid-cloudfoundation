module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = var.tgw_name
  description = var.tgw_description

  enable_auto_accept_shared_attachments = var.enable_auto_accept_shared_attachments

  ram_allow_external_principals = var.ram_allow_external_principals
  ram_principals                = var.ram_principals
  transit_gateway_cidr_blocks   = var.transit_gateway_cidr_blocks

  tags = var.ram_tags
}
