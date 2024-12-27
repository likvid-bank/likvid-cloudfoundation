output "management_account_id" {
  value       = module.meshplatform.management_account_id
  description = "Management Account ID"
}

output "meshcloud_account_id" {
  value       = module.meshplatform.meshcloud_account_id
  description = "Meshcloud Account ID"
}

output "automation_account_id" {
  value       = module.meshplatform.automation_account_id
  description = "Automation Account ID"
}

output "replicator_aws_iam_keys" {
  value       = module.meshplatform.replicator_aws_iam_keys
  description = "You can access your credentials when you execute `terraform output replicator_aws_iam_keys` command"
  sensitive   = true
}

output "replicator_privileged_external_id" {
  value       = module.meshplatform.replicator_privileged_external_id
  description = "Replicator privileged_external_id"
  sensitive   = true
}

output "replicator_workload_identity_federation_role" {
  value = module.meshplatform.replicator_workload_identity_federation_role
}

output "metering_aws_iam_keys" {
  value       = module.meshplatform.metering_aws_iam_keys
  description = "You can access your credentials when you execute `terraform output kraken_aws_iam_keys` command"
  sensitive   = true
}

output "cost_explorer_privileged_external_id" {
  value       = module.meshplatform.cost_explorer_privileged_external_id
  description = "Cost explorer privileged_external_id"
  sensitive   = true
}

output "metering_workload_identity_federation_role" {
  value = module.meshplatform.cost_explorer_identity_federation_role
}
