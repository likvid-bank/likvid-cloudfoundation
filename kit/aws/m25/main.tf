resource "aws_organizations_organizational_unit" "platform" {
  name      = "likvid-m25-platform"
  parent_id = var.parent_ou_id
}
