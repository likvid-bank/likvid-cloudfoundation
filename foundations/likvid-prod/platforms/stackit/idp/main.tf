
terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19.0"
    }
  }

  backend "s3" {
    bucket         = "likvid-tf-state"
    key            = "platforms/stackit/idp.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::490004649140:role/OrganizationAccountAccessRole"
    profile        = "likvid" # omit or set to null in CI (when CI=true)
  }
}

data "meshstack_workspace" "devops_platform" {
  metadata = {
    name = "devops-platform"
  }
}

module "buildingblock_git_repo" {
  # todo replace with reference to hub once published there
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/stackit/git-repository?ref=c5d88df9f6d5b736316effc13172e3c50819c79a"

  gitea_token = var.gitea_token

  # stackit_project_id = "272f2ba5-fa0a-4b8b-8ceb-e68165a87914"
  gitea_base_url              = "https://git-service.git.onstackit.cloud" # module.git_repo_backplane.gitea_base_url
  gitea_organization          = "likvid"
  owning_workspace_identifier = data.meshstack_workspace.devops_platform.metadata.name
}