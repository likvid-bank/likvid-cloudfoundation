terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.9.0"
    }

    # 0.24.3 added the `meshstack_platforms` data source every `platform_ref` in this kit resolves
    # through, so it is the true floor: 0.24.0 through 0.24.2 cannot resolve this module at all, and
    # 0.21.0 through 0.23.3 still carry the old identifier schema under the name `meshstack_tenant`.
    # The two `meshstack_tenant_v4` moves this kit needed were applied on 0.24.5 and their `moved`
    # blocks removed, so 0.25.0 dropping that type and its mover no longer affects this unit.
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.24.3"
    }

    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}
