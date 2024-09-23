resource "aws_organizations_organizational_unit" "on_prem" {
  parent_id = var.parent_ou_id
  name      = "on-prem"
}

resource "aws_organizations_organizational_unit" "dev" {
  parent_id = aws_organizations_organizational_unit.on_prem.id
  name      = "dev"
}

resource "aws_organizations_organizational_unit" "prod" {
  parent_id = aws_organizations_organizational_unit.on_prem.id
  name      = "prod"
}
