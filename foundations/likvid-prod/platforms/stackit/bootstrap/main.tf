resource "stackit_resourcemanager_project" "management" {
  parent_container_id = var.organization_id
  name                = "likvid-cloudfoundation-management"
  owner_email         = "jrudolph@meshcloud.io"
}


ephemeral "stackit_access_token" "token" {}

resource "null_resource" "platform_admin" {

  # Trigger creation and destruction of resources based on the lifecycle
  triggers = {
    members         = jsonencode(var.platform_admins)
    url             = var.api_url
    organization_id = var.organization_id
  }

  # Provisioner for the 'create' action
  provisioner "local-exec" {
    when    = create
    command = <<EOT
curl -X PATCH "${self.triggers.url}/v2/${self.triggers.organization_id}/members" \
-H "Authorization: Bearer ${ephemeral.stackit_access_token.token.access_token}" \
-H "Content-Type: application/json" \
-d '{
  "members": ${self.triggers.members},
  "resourceType": "organization"
}'
EOT
  }
  # Provisioner for the 'destroy' action
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
TOKEN=$(stackit auth get-access-token)
curl -X POST "${self.triggers.url}/v2/${self.triggers.organization_id}/members/remove" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
 "forceRemove": true,
  "members": ${self.triggers.members},
  "resourceType": "organization"
}'
EOT
  }
}

resource "null_resource" "platform_users" {
  # Trigger creation and destruction of resources based on the lifecycle
  triggers = {
    members         = jsonencode(var.platform_users)
    url             = var.api_url
    organization_id = var.organization_id
  }

  # Provisioner for the 'create' action
  provisioner "local-exec" {
    when    = create
    command = <<EOT
curl -X PATCH "${self.triggers.url}/v2/${self.triggers.organization_id}/members" \
-H "Authorization: Bearer ${ephemeral.stackit_access_token.token.access_token}" \
-H "Content-Type: application/json" \
-d '{
  "members": ${self.triggers.members},
  "resourceType": "organization"
}'
EOT
  }
  # Provisioner for the 'destroy' action
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
TOKEN=$(stackit auth get-access-token)
curl -X POST "${self.triggers.url}/v2/${self.triggers.organization_id}/members/remove" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
 "forceRemove": true,
  "members": ${self.triggers.members},
  "resourceType": "organization"
}'
EOT
  }
}
