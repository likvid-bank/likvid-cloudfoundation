## METERING
output "metering_token" {
  value     = module.aks_meshplatform.metering_token
  sensitive = true
}

output "metering_expose_token" {
  value = module.aks_meshplatform.metering_expose_token
}


## REPLICATOR

output "replicator_token" {
  value     = module.aks_meshplatform.replicator_token
  sensitive = true
}

output "replicator_expose_token" {
  value = module.aks_meshplatform.replicator_expose_token
}
