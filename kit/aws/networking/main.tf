module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = var.tgw_name
  description = var.tgw_description

  enable_auto_accept_shared_attachments = var.enable_auto_accept_shared_attachments

  ram_allow_external_principals = var.ram_allow_external_principals
  ram_principals                = [var.ram_principals]

  tags = [var.tgw_tags]
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 3.0"

#   name = "my-vpc"

#   cidr = "10.10.0.0/16"

#   azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
#   private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]

#   enable_ipv6                                    = true
#   private_subnet_assign_ipv6_address_on_creation = true
#   private_subnet_ipv6_prefixes                   = [0, 1, 2]
# }
