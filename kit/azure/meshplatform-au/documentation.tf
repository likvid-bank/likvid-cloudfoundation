output "documentation_md" {
  value = <<EOF
# meshStack Integration

meshStack integration sets up this AAD tenant as a meshPlatform.
To do this we create AAD tenant-level service principals, allowing meshStack to access data
and orchestrate Azure platform functionality.

## Replicator Service Principal

In order to manage user roles and permissions, meshcloud requires a Service Principal for the replicator
which is placed in the AAD Tenant containing your Azure Subscriptions and workloads. The Service Principal must be authorized in the scope of this AAD Tenant.

 - Application Client ID: ${module.meshplatform.replicator_service_principal["Application_Client_ID"]}
 - Enterprise Application Object ID: ${module.meshplatform.replicator_service_principal["Enterprise_Application_Object_ID"]}

> To fetch client secret for replicator: execute `collie foundation deploy <foundation> --platform azure --module "meshplatform" -- output replicator_client_secret`


Cloud Platforms record events and other information about deployed cloud resources. Some of these events are relevant for metering. To read resource usage,
a metering principal is needed.

## Microsoft Customer Agreement (MCA) Service Principal(s)

For MCA subscription provisioning type, in addition to replicator, a service principal is created in the AAD tenant with the billing account (Source AAD tenant).

This service principal has "Azure subscription creator" role on the invoice section level (Billing Account -> Billing Profile -> Invoice Section).

${var.mca != null ? join("\n",
  ["Following MCA SPs are created:"],
  [join("\n", [for name, properties in module.meshplatform.mca_service_principal : <<EOT

**${name}**:

- Application Client ID: ${properties.Application_Client_ID}
- Enterprise Application Object ID: ${properties.Enterprise_Application_Object_ID}
EOT
])], ["> To fetch client secrets for all MCA SPs: execute `collie foundation deploy meshcloud-prod --platform azure --module \"meshplatform\" -- output mca_client_secret` (intentionally using meshcloud-prod foundation)"])
: "> MCA service principal is setup from meshcloud-prod foundation, since MCA lives there."
}

## Metering Service Principal

 - Application Client ID: ${module.meshplatform.metering_service_principal["Application_Client_ID"]}
 - Enterprise Application Object ID: ${module.meshplatform.metering_service_principal["Enterprise_Application_Object_ID"]}

> To fetch client secret for metering: execute `collie foundation deploy <foundation> --platform azure --module "meshplatform" -- output metering_client_secret`

EOF
}
