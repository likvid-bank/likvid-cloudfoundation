
# # iterate through the list of users and redue to a map of user with only their euid
# locals {
#   first_admin = [for user in var.users : user if contains(user.roles, "admin")][0]
# }

# resource "null_resource" "create_contract" {
#   provisioner "local-exec" {
#     command = <<EOT
#       CONTRACT_RESPONSE=$(curl --location --request POST 'https://api.ionos.com/reseller/v2/contracts' \
#       --header 'Authorization: Basic ${var.token}' \
#       --header 'Content-Type: application/json' \
#       --data-raw '{
#           "name": "co-${var.workspace_identifier}-${var.project_identifier}",
#           "resellerReference": "${var.reseller_reference}",
#           "resourceLimits": {
#               "ramServerMax": ${var.ram_server_max},
#               "cpuServerMax": ${var.cpu_server_max},
#               "hddVolumeMaxSize": ${var.hdd_volume_max_size},
#               "ssdVolumeMaxSize": ${var.ssd_volume_max_size},
#               "ramContractMax": ${var.ram_contract_max},
#               "cpuContractMax": ${var.cpu_contract_max},
#               "hddVolumeContractMaxSize": ${var.hdd_volume_contract_max_size},
#               "ssdVolumeContractMaxSize": ${var.ssd_volume_contract_max_size},
#               "ips": ${var.ips}
#           }
#       }')

#       CONTRACT_ID=$(echo $CONTRACT_RESPONSE | jq -r '.id')

#       curl --location --request POST "https://api.ionos.com/reseller/v2/contracts/$${CONTRACT_ID}/admins" \
#       --header 'Authorization: Basic ${var.token}' \
#       --header 'Content-Type: application/json' \
#       --data-raw '{
#           "firstName": "${local.first_admin.firstName}",
#           "lastName": "${local.first_admin.lastName}",
#           "email": "${local.first_admin.email}",
#           "password": "${var.password}"
#       }'
#     EOT
#   }
# }

# data "external" "create_contract" {
#   program = [
#     "${path.module}/contract.sh",
#     var.token,
#     "co-${var.workspace_identifier}-${var.project_identifier}",
#     var.reseller_reference,
#     var.ram_server_max,
#     var.cpu_server_max,
#     var.hdd_volume_max_size,
#     var.ssd_volume_max_size,
#     var.ram_contract_max,
#     var.cpu_contract_max,
#     var.hdd_volume_contract_max_size,
#     var.ssd_volume_contract_max_size,
#     var.ips
#   ]
# }

# output "contract_id" {
#   value = data.external.create_contract.result.contract_id
# }

resource "restapi_object" "contract" {
  path = "/contracts"
  data = jsonencode({
    name              = "co-${var.workspace_identifier}-${var.project_identifier}"
    resellerReference = var.reseller_reference
    resourceLimits = {
      ramServerMax             = var.ram_server_max
      cpuServerMax             = var.cpu_server_max
      hddVolumeMaxSize         = var.hdd_volume_max_size
      ssdVolumeMaxSize         = var.ssd_volume_max_size
      ramContractMax           = var.ram_contract_max
      cpuContractMax           = var.cpu_contract_max
      hddVolumeContractMaxSize = var.hdd_volume_contract_max_size
      ssdVolumeContractMaxSize = var.ssd_volume_contract_max_size
      ips                      = var.ips
    }
  })
}

# resource "random_password" "password" {
#   length = 12
# }

# # # Deklarative Erstellung des Admin-Users basierend auf der Contract-ID
# resource "restapi_object" "admin_user" {
#   path = "/contracts/${restapi_object.contract.id}/admins"
#   #method = "POST"
#   data = jsonencode({
#     firstName = local.first_admin.firstName
#     lastName  = local.first_admin.lastName
#     email     = local.first_admin.email
#     password  = random_password.password.result
#   })
# }

# locals {
#   admin = [for user in var.users : user if contains(user.roles, "admin")][0]
# }
