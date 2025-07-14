resource "meshstack_tenant" "repo" {
  metadata = {
    owned_by_workspace  = var.workspace_identifier
    owned_by_project    = var.project_identifier
    platform_identifier = "github-repository.devtools"
  }

  spec = {
    landing_zone_identifier = "github-repository-for-starter-kit"
  }
}

resource "time_sleep" "wait" {
  depends_on = [meshstack_tenant.repo]

  create_duration = "2m"
}

resource "meshstack_buildingblock" "pre_github_actions_terraform_setup" {
 depends_on = [time_sleep.wait]
 metadata = {
    definition_uuid    = "5ef1ac36-72bb-4524-8af7-f28f976038fd"
    definition_version = 1
    tenant_identifier  = "${var.workspace_identifier}.${var.project_identifier}.azure.meshcloud-azure-dev"
  }

  spec = {
    display_name = "Pre GitHub Actions Terraform Setup"
  }
   

resource "meshstack_buildingblock" "github_actions_terraform_setup" {
  depends_on = [meshstack_buildingblock.pre_github_actions_terraform_setup]

  metadata = {
    definition_uuid    = "129bcf9e-180d-471c-bd38-b9a49a320d87"
    definition_version = 13
    tenant_identifier  = "${var.workspace_identifier}.${var.project_identifier}.azure.meshcloud-azure-dev"
  }

  spec = {
    display_name = "GitHub Actions Terraform Setup"
    parent_building_blocks = [{
      buildingblock_uuid = meshstack_building_block_v2.repo.metadata.uuid
      definition_uuid    = "5ef1ac36-72bb-4524-8af7-f28f976038fd"
    }]
    
    inputs = {
      repo_name = { value_string = var.project_identifier }
    }
  }
}

