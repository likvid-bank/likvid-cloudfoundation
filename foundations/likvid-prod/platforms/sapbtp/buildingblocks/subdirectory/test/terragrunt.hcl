include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "${get_repo_root()}//kit/sapbtp/buildingblocks/subdirectory/buildingblock"
}

inputs = {
  subfolder     = "likvid-a-001"
  parent_id     = "99f8ad5f-255e-46a5-a72d-f6d652c90525"
  globalaccount = "meshcloudgmbh"
  #  workspace_identifier = "sap-core-platform"
  project_identifier = "sap-bt"
  #   users = [
  #     {
  #       meshIdentifier = "identifier1"
  #       username       = "testuser1@likvid.io"
  #       firstName      = "test"
  #       lastName       = "user"
  #       email          = "testuser1@likvid.io"
  #       euid           = "testuser1@likvid.io"
  #       roles          = ["admin", "user"]
  #     },

  #     {
  #       meshIdentifier = "identifier2"
  #       username       = "testuser2@likvid.io"
  #       firstName      = "test"
  #       lastName       = "user"
  #       email          = "testuser2@likvid.io"
  #       euid           = "testuser2@likvid.io"
  #       roles          = ["admin"]
  #     }
  #   ]
}
