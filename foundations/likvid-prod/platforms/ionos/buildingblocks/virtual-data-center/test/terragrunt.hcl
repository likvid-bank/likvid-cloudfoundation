include "common" {
  path = find_in_parent_folders("common.hcl")
}


terraform {
  source = "${get_repo_root()}//kit/ionos/buildingblocks/virtual-data-center/buildingblock"
}

inputs = {}
