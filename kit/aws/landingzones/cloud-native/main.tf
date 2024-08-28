resource "aws_organizations_organizational_unit" "cloud_native" {
  parent_id = var.parent_ou_id
  name      = "cloud-native"
}

resource "aws_organizations_organizational_unit" "dev" {
  parent_id = aws_organizations_organizational_unit.cloud_native.id
  name      = "dev"
}

resource "aws_organizations_organizational_unit" "prod" {
  parent_id = aws_organizations_organizational_unit.cloud_native.id
  name      = "prod"
}