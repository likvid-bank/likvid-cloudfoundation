resource "meshstack_project" "project" {
  metadata = {
    name               = var.project_name
    owned_by_workspace = var.workspace_identifier
  }

  spec = {
    display_name = var.project_name

    tags = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["sandbox"]
      "Schutzbedarf"         = ["public"]
    }
  }
}

resource "meshstack_tenant" "azure" {
  metadata = {
    owned_by_workspace  = var.workspace_identifier
    owned_by_project    = meshstack_project.project.metadata.name
    platform_identifier = "azure.meshcloud-azure-dev"
  }

  spec = {
    landing_zone_identifier = "likvid-azure-sandbox"
  }
}

resource "meshstack_building_block_v2" "repo" {
  spec = {
    building_block_definition_version_ref = {
      uuid = "2a17061b-e0c6-400d-a589-4597c44ee84a"
    }

    display_name = "GitHub Repo ${var.repo_name}"
    target_ref = {
      kind       = "meshWorkspace"
      identifier = var.workspace_identifier
    }

    inputs = {
      repo_name = {
        value_string = var.repo_name
      }

      template_owner = {
        value_string = "likvid-bank"
      }

      template_repo = {
        value_string = "starterkit-template-azure-static-website"
      }

      use_template = {
        value_bool = true
      }
    }
  }
}

resource "time_sleep" "wait" {
  depends_on = [meshstack_building_block_v2.repo]

  create_duration = "2m"
}

resource "meshstack_buildingblock" "github_actions_terraform_setup" {
  depends_on = [time_sleep.wait]

  metadata = {
    definition_uuid    = "129bcf9e-180d-471c-bd38-b9a49a320d87"
    definition_version = 9
    tenant_identifier  = "${var.workspace_identifier}.${var.project_name}.azure.meshcloud-azure-dev"
  }

  spec = {
    display_name = "GitHub Actions Terraform Setup"

    inputs = {
      repo_name = { value_string = var.repo_name }
    }
  }
}


