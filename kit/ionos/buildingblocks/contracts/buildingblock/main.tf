
# iterate through the list of users and redue to a map of user with only their euid
# locals {
#   #reader = { for user in var.users : user.euid => user if contains(user.roles, "reader") }
#   admin = { for user in var.users : user.euid => user if contains(user.roles, "admin") }
#   #user   = { for user in var.users : user.euid => user if contains(user.roles, "user") }
# }

resource "null_resource" "create_contract" {
  provisioner "local-exec" {
    command = <<EOT
      CONTRACT_RESPONSE=$(curl --location --request POST 'https://api.ionos.com/reseller/v2/contracts' \
      --header 'Authorization: Basic ${var.token}' \
      --header 'Content-Type: application/json' \
      --data-raw '{
          "name": "co-${var.workspace_identifier}-${var.project_identifier}",
          "resellerReference": "${var.reseller_reference}",
          "resourceLimits": {
              "ramServerMax": ${var.ram_server_max},
              "cpuServerMax": ${var.cpu_server_max},
              "hddVolumeMaxSize": ${var.hdd_volume_max_size},
              "ssdVolumeMaxSize": ${var.ssd_volume_max_size},
              "ramContractMax": ${var.ram_contract_max},
              "cpuContractMax": ${var.cpu_contract_max},
              "hddVolumeContractMaxSize": ${var.hdd_volume_contract_max_size},
              "ssdVolumeContractMaxSize": ${var.ssd_volume_contract_max_size},
              "ips": ${var.ips}
          }
      }')

      CONTRACT_ID=$(echo $CONTRACT_RESPONSE | jq -r '.id')

      curl --location --request POST "https://api.ionos.com/reseller/v2/contracts/$${CONTRACT_ID}/admins" \
      --header 'Authorization: Basic ${var.token}' \
      --header 'Content-Type: application/json' \
      --data-raw '{
          "firstName": "${var.first_name}",
          "lastName": "${var.last_name}",
          "email": "${var.email}",
          "password": "${var.password}"
      }'
    EOT
  }
}
