output "dev_ou_id" {
  description = "organizational unit id for the dev OU"
  value       = aws_organizations_organizational_unit.dev.id
}

output "dev_ou_arn" {
  description = "organizational unit arn for the dev OU"
  value       = aws_organizations_organizational_unit.dev.arn
}

output "prod_ou_id" {
  description = "organizational unit id for the prod OU"
  value       = aws_organizations_organizational_unit.prod.id
}

output "prod_ou_arn" {
  description = "organizational unit arn for the prod OU"
  value       = aws_organizations_organizational_unit.prod.arn
}
