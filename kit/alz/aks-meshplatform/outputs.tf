## METERING
output "metering_token" {
  value     = module.meshcloud-service-account-meshfed-metering.0.token_metering
  sensitive = true
}

output "metering_expose_token" {
  value = module.meshcloud-service-account-meshfed-metering.0.expose_token
}


## REPLICATOR

output "replicator_token" {
  value     = module.meshcloud-service-account-meshfed-replicator.0.token_replicator
  sensitive = true
}

output "replicator_expose_token" {
  value = module.meshcloud-service-account-meshfed-replicator.0.expose_token
}
