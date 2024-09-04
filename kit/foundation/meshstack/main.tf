locals {
  meshobject_dir    = "${path.module}/meshobjects"
  meshobjects_files = { for x in fileset(local.meshobject_dir, "**/*.yml") : x => yamldecode(file("${local.meshobject_dir}/${x}")) }
}

locals {
  headers = {
    contentType   = "Content-Type: application/vnd.meshcloud.api.meshobjects.v1+yaml;charset=UTF-8"
    accept        = "Accept: application/vnd.meshcloud.api.meshobjects.v1+json"
    authorization = "Authorization: Basic ${base64encode("${var.meshstack_api.username}:${var.meshstack_api.password}")}"
  }
}


# todo: replace by tag definition resources once supported
locals {
  tags = {
    BusinessUnit = "BusinessUnit"
  }
  policies = {
    RestrictLandingZoneToWorkspaceBusinessUnit = {
      policy      = "Workspace.${local.tags.BusinessUnit} --> LandingZone.${local.tags.BusinessUnit}"
      description = "This policy restricts access to specific landing zones based on the business unit of the workspace. This policy enables platform teams that support specific business units to offer their services to workspaces from that business unit only."
    }
    RestrictBuildingBlockToWorkspaceBusinessUnit = {
      policy      = "Workspace.${local.tags.BusinessUnit} --> BuildingBlock.${local.tags.BusinessUnit}"
      description = "This policy restricts access to specific building blocks based on the business unit of the workspace. This policy enables platform teams that support specific business units to offer their services to workspaces from that business unit only."
    }
  }

  landingZones = {
    m25-cloud-native = {
      name = "m25-cloud-native"
      spec = {
        displayName = "M25 Cloud Native"
        tags = {
          BusinessUnit = ["M25"]
        }
      }
    }
  }

  buildingBlockDefinitions = {
    m25-domain = {
      name = "m25-domain"
      spec = {
        displayName = "M25 Domain"
        description = "Request a subdomain for *.m25.com"
        tags = {
          BusinessUnit = ["M25"]
        }
      }
    }

    # WIP
    m25-static-website-assets = {
      name = "static-website-assets"
      spec = {
        displayName = "M25 Static Website Assets"
        description = "Order an S3 bucket to host your static website"
        tags = {
          BusinessUnit = ["M25"]
          Environment  = ["prod", "dev", "qa", "test"]
        }
      }
    }
  }
}

resource "terraform_data" "meshobjects_import" {
  for_each = local.meshobjects_files

  input            = each.value
  triggers_replace = each.value # this is a PUT API, so mostly safe (does not support deletes though)

  provisioner "local-exec" {
    when    = create
    command = <<EOF
curl -X PUT ${var.meshstack_api.endpoint}/api/meshobjects \
  -H '${local.headers.contentType}' \
  -H '${local.headers.accept}' \
  -H '${local.headers.authorization}' \
  --data-binary '@${local.meshobject_dir}/${each.key}'
EOF
  }
}
