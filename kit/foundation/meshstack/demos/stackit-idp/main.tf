module "stackit_git_repo_backplane" {
  source = "./backplane"

  # Backplane outputs – wire these from your backplane module outputs
  gitea_base_url     = var.gitea_base_url
  gitea_token        = var.gitea_token       
  gitea_organization = var.gitea_organization
}

resource "meshstack_building_block_definition" "stackit_git_repo" {
  metadata = {
    owned_by_workspace = var.workspace
  }

  spec = {
    display_name      = "STACKIT Git Repository"
    symbol            = "🗂️"
    description       = "Provisions a Git repository on STACKIT Git (Forgejo/Gitea) with optional template initialization and CI/CD webhook configuration."
    support_url       = "https://git-service.git.onstackit.cloud"
    target_type       = "WORKSPACE_LEVEL"
    run_transparency  = true
    supported_platforms = [
      { name = "STACKIT" }
    ]
  }

  version_spec = {
    draft         = true
    deletion_mode = "DELETE"

    implementation = {
      terraform = {
        terraform_version = "1.9.0"
        # TODO: meshStack Hub
        repository_url    = "https://github.com/likvid-bank/likvid-cloudfoundation.git"
        repository_path   = "kit/stackit/buildingblocks/git-repo/buildingblock"
        ref_name          = "main"
        async             = false
      }
    }

    inputs = {
      # ── Static inputs from backplane ──────────────────────────────────────

      gitea_base_url = {
        display_name    = "STACKIT Git Base URL"
        description     = "Base URL of the STACKIT Git instance"
        type            = "STRING"
        assignment_type = "STATIC"
        argument        = jsonencode(local.gitea_base_url)
      }

      gitea_token = {
        display_name    = "STACKIT Git API Token"
        description     = "Personal Access Token for the STACKIT Git API"
        type            = "STRING"
        assignment_type = "STATIC"
        sensitive = {
          argument = {
            secret_value = local.gitea_token
          }
        }
      }

      gitea_organization = {
        display_name    = "STACKIT Git Organization"
        description     = "Organization under which repositories will be created"
        type            = "STRING"
        assignment_type = "STATIC"
        argument        = jsonencode(local.gitea_organization)
      }

      # ── User inputs ────────────────────────────────────────────────────────

      repository_name = {
        display_name               = "Repository Name"
        description                = "Name of the Git repository (alphanumeric, dashes, dots, underscores)"
        type                       = "STRING"
        assignment_type            = "USER_INPUT"
        value_validation_regex     = "^[a-zA-Z0-9._-]+$"
        validation_regex_error_message = "Only alphanumeric characters, dots, dashes, and underscores are allowed."
      }

      repository_description = {
        display_name    = "Repository Description"
        description     = "Short description of the repository"
        type            = "STRING"
        assignment_type = "USER_INPUT"
        default_value   = jsonencode("")
      }

      repository_private = {
        display_name    = "Private Repository"
        description     = "Whether the repository should be private"
        type            = "BOOLEAN"
        assignment_type = "USER_INPUT"
        default_value   = jsonencode(true)
      }

      use_template = {
        display_name    = "Create from Template"
        description     = "Initialize the repository from a pre-configured application template"
        type            = "BOOLEAN"
        assignment_type = "USER_INPUT"
        default_value   = jsonencode(false)
      }

      template_name = {
        display_name      = "Template Name"
        description       = "Name of the template repository to use (only relevant when 'Create from Template' is enabled)"
        type              = "SINGLE_SELECT"
        assignment_type   = "USER_INPUT"
        selectable_values = ["app-template-python", "app-template-nodejs", "app-template-java"]
        default_value     = jsonencode("app-template-python")
      }

      webhook_url = {
        display_name    = "Webhook URL"
        description     = "Optional: Webhook URL to trigger CI/CD builds (e.g., Argo Workflows EventSource). Leave empty to skip."
        type            = "STRING"
        assignment_type = "USER_INPUT"
        default_value   = jsonencode("")
      }
    }

    outputs = {
      repository_html_url = {
        display_name    = "Repository URL"
        type            = "STRING"
        assignment_type = "RESOURCE_URL"
      }

      repository_clone_url = {
        display_name    = "HTTPS Clone URL"
        type            = "STRING"
        assignment_type = "NONE"
      }

      repository_ssh_url = {
        display_name    = "SSH Clone URL"
        type            = "STRING"
        assignment_type = "NONE"
      }

      summary = {
        display_name    = "Summary"
        type            = "STRING"
        assignment_type = "SUMMARY"
      }
    }
  }
}
