resource "stackit_resourcemanager_project" "example" {
  parent_container_id = "0a4006f8-eaf3-417c-b2fa-7e9c08ebffba"
  name                = "test2"
  labels = {
    "Label1" = "foo"
  }
  owner_email = "fnowarre@meshcloud.io"
}

resource "null_resource" "project_admin" {
  # Trigger creation and destruction of resources based on the lifecycle
  triggers = {
    members    = jsonencode(var.members)
    url        = var.api_url
    token      = var.token
    project_id = stackit_resourcemanager_project.example.project_id
  }

  # Provisioner for the 'create' action
  provisioner "local-exec" {
    when    = create
    command = <<EOT
curl -X PATCH "${self.triggers.url}/v2/${self.triggers.project_id}/members" \
-H "Authorization: Bearer ${self.triggers.token}" \
-H "Content-Type: application/json" \
-d '{
  "members": ${self.triggers.members},
  "resourceType": "project"
}'
EOT
  }

  # Provisioner for the 'destroy' action
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
curl -X POST "${self.triggers.url}/v2/${self.triggers.project_id}/members/remove" \
-H "Authorization: Bearer ${self.triggers.token}" \
-H "Content-Type: application/json" \
-d '{
 "forceRemove": true,
  "members": ${self.triggers.members},
  "resourceType": "project"
}'
EOT
  }
}

