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

  # TODO: missing ones
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

    github-repository = {
      name = "github-repository"
      spec = {
        displayName = "GitHub Repository"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    sap-core-platform = {
      name = "likvid-sapbtp-dev"
      spec = {
        displayName = "SAP Core Platform"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    ionos-dev = {
      name = "likvid-ionos-dev"
      spec = {
        displayName = "Likvid Ionos dev"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    ionos-prod = {
      name = "likvid-ionos-prod"
      spec = {
        displayName = "Likvid Ionos Prod"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    stackit-dev = {
      name = "likvid-stackit-dev"
      spec = {
        displayName = "Likvid stackit dev"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    stackit-prod = {
      name = "likvid-stackit-prod"
      spec = {
        displayName = "Likvid stackit Prod"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }
  }
  customPlatformDefinitions = {
    github-repository = {
      name = "github-repository"
      spec = {
        displayName       = "GitHub Repository"
        description       = "Provisions a GitHub Repository in our Likvid Bank GitHub organization. It can be an empty repository or sourced from a template."
        web-console-url   = "https://github.com/likvid-bank"
        support-url       = "https://meshcloud.slack.com/archives/C0681JFCUQP"
        documentation-url = "https://likvid-bank.github.io/likvid-cloudfoundation/meshstack.html"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    sap-core-platform = {
      name = "sap-core-platform"
      spec = {
        displayName       = "SAP BTP core Platform"
        description       = "Provisions a Subaccount in our Likvid Bank SAP BTP Environment."
        web-console-url   = "https://emea.cockpit.btp.cloud.sap"
        support-url       = "https://meshcloud.slack.com/archives/C0681JFCUQP"
        documentation-url = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/sapbtp/bootstrap.html"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    ionos = {
      name = "Ionos"
      spec = {
        displayName       = "Ionos"
        description       = "This platform only has German locations. It is suitable for workloads in the Schutzklassen Grundschutz-hoch and Grundschutz-normal protection classes."
        web-console-url   = "https://dcd.ionos.com/"
        support-url       = "https://meshcloud.slack.com/archives/C0681JFCUQP"
        documentation-url = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/ionos/bootstrap.html"
        tags = {
          BusinessUnit = ["IT"]
        }
      }
    }

    stackit = {
      name = "stackit"
      spec = {
        displayName       = "stackit"
        description       = "Likvid Bank provides a European cloud solution via meshStack, enabling DSGVO-compliant workload provisioning for state-affiliated institutions."
        web-console-url   = "https://portal.stackit.cloud/projects"
        support-url       = "https://meshcloud.slack.com/archives/C0681JFCUQP"
        documentation-url = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/stackit/bootstrap.html"
        tags = {
          BusinessUnit = ["IT"]
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

    github-repository = {
      name = "github-repository"
      spec = {
        displayName       = "GitHub Repository"
        description       = "Provisions a GitHub Repository in our Likvid Bank GitHub organization. It can be an empty repository or sourced from a template."
        web-console-url   = "https://github.com/likvid-bank"
        support-url       = "https://meshcloud.slack.com/archives/C0681JFCUQP"
        documentation-url = "https://likvid-bank.github.io/likvid-cloudfoundation/meshstack.html"
      }
    }

    sapbtp-subaccounts-repository = {
      name = "sapbtp-subaccounts-repository "
      spec = {
        displayName = "SAP BTP Subaccounts"
        description = "Provisions environments (subaccounts) in SAP BTP via terraform."
      }
    }

    ionos-virtual-data-center = {
      name = "Ionos Virtual Data Center"
      spec = {
        displayName = "Ionos Virtual Data Center"
        description = "Your IONOS Cloud infrastructure is set up in Virtual Data Centers (VDCs). Here you will find all the resources required to configure and manage your products and services."
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
curl --fail -X PUT ${var.meshstack_api.endpoint}/api/meshobjects \
  -H '${local.headers.contentType}' \
  -H '${local.headers.accept}' \
  -H '${local.headers.authorization}' \
  --data-binary '@${local.meshobject_dir}/${each.key}'
EOF
  }
}
