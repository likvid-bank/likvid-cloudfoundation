include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "platform" {
  config_path                             = "../meshstack"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    owned_by_workspace = "likvid-cloud"
    platform_ref = {
      uuid = "00000000-0000-0000-0000-000000000000"
      kind = "meshPlatform"
    }
    landing_zone_refs = {
      dev  = { name = "okd-gcp-dev", kind = "meshLandingZone" }
      prod = { name = "okd-gcp-prod", kind = "meshLandingZone" }
    }
  }
}

locals {
  openshift_api_server_url = "https://api.dev.okd.msh.host:6443"

  # Kubeconfig of the `terraform` service account in namespace `likvid-cloudfoundation` (cluster-admin).
  okd_kubeconfig = pathexpand(get_env("OKD_KUBECONFIG", "~/.kube/okd-gcp"))
}

# Without a kubeconfig the kubernetes provider falls back to system:anonymous, which fails halfway
# through an apply after the meshStack resources have already been created.
terraform {
  before_hook "require_okd_kubeconfig" {
    commands = ["plan", "apply"]
    execute  = ["bash", "-c", "[ -f '${local.okd_kubeconfig}' ] || { echo 'No kubeconfig for the okd-gcp cluster at ${local.okd_kubeconfig}; set OKD_KUBECONFIG.' >&2; exit 1; }"]
  }
}

# The kubernetes provider is used by the openshift/github-connector backplane, which sets up the
# service account the connector building block runs with. It needs cluster-admin on the cluster.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  config_path = "${local.okd_kubeconfig}"
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

inputs = {
  meshstack = {
    owning_workspace_identifier = dependency.platform.outputs.owned_by_workspace
  }

  hub = include.hub.locals

  github = {
    org                 = "likvid-bank"
    app_id              = "654209"
    app_installation_id = "44437049"
    app_pem_file        = get_env("GITHUB_APP_PEM_FILE")
  }

  platform_ref      = dependency.platform.outputs.platform_ref
  landing_zone_refs = dependency.platform.outputs.landing_zone_refs

  openshift = {
    api_server_url = local.openshift_api_server_url
    apps_domain    = "apps.dev.okd.msh.host"
    registry_host  = "default-route-openshift-image-registry.apps.dev.okd.msh.host"
  }

  # "GitHub Repository Creation" of the AKS starter kit (workspace devops-platform), version 6.
  github_repo_definition = {
    uuid         = "1aeeefa8-5919-49d1-ad88-7f0c436c25e9"
    version_uuid = "8c3b31b7-f938-44b2-a71e-886103e3dedd"
  }

  github_template_repo_path = "likvid-bank/openshift-app-template"
  github_workflow_filename  = "openshift-deploy.yml"

  project_tags = {
    stages = {
      dev = {
        "environment"          = ["dev"]
        "LandingZoneClearance" = ["container-platform"]
        "Schutzbedarf"         = ["internal"]
        "projectOwner"         = ["Platform Team"]
      }
      prod = {
        "environment"          = ["prod"]
        "LandingZoneClearance" = ["container-platform"]
        "Schutzbedarf"         = ["public"]
        "projectOwner"         = ["Platform Team"]
      }
    }
  }
}
