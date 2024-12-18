locals {
  admins  = { for user in var.users : user.username => user if contains(user["roles"], "admin") }
  editors = { for user in var.users : user.username => user if contains(user["roles"], "user") }
  readers = { for user in var.users : user.username => user if contains(user["roles"], "reader") }
}

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

data "ionoscloud_user" "admins" {
  for_each   = local.admins
  email      = each.value.username
  depends_on = [restapi_object.contract]
}

data "ionoscloud_user" "editors" {
  for_each   = local.editors
  email      = each.value.username
  depends_on = [restapi_object.contract]
}

data "ionoscloud_user" "readers" {
  for_each   = local.readers
  email      = each.value.username
  depends_on = [restapi_object.contract]
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
