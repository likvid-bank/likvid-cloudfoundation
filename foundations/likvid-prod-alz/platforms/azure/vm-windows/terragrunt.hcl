include "platform" {
    path = find_in_parent_folders("platform.hcl")
    expose = true
  }

include "module" {
    path = find_in_parent_folders("module.hcl")
  }

terraform {
    source = "${get_repo_root()}//kit/alz/vm-windows"
  }

inputs = {
    aadTenantId = "${include.platform.locals.platform.azure.aadTenantId}"
    keyvault_user_object_id = {
      "mkazemi" = "68496213-91f0-4504-9fc7-69fe75a4994e"
      "jo"  = "0fb37375-1e58-4c04-a7c2-03ef34afb686"
      "tfelix" = "527acf06-eb40-44db-ac4c-c4c8d0b8907b"
      "fzieger" = "8bec23a9-2599-4294-93c6-11eeaa1dc2cb"
    }
  }