resource "terraform_data" "replacement" {
  input = {
    github_token               = var.github_token
    github_repo                = var.github_repo
    github_owner               = var.github_owner
    workflow_branch            = var.workflow_branch
    workflow_destroy_file_name = var.workflow_destroy_file_name
    meshstack_building_block_run_b64 = var.meshstack_building_block_run_b64
  }

  triggers_replace = [
    var.meshstack_building_block_run_b64,
  ]

  provisioner "local-exec" {
    when = create
    environment = {
      run_data = jsondecode(base64decode(var.meshstack_building_block_run_b64)).spec.behavior
    }
    command = <<EOT
      set -e
      if [ "$run_data" = "DESTROY" ]; then
        exit 0
      fi
      curl --fail-with-body -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${var.github_token}" \
        https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/workflows/${var.workflow_create_file_name}/dispatches \
        -d "{\"ref\":\"${var.workflow_branch}\", \"inputs\": {\"bb-run\":\"${var.meshstack_building_block_run_b64}\"}}"
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      run_data = jsondecode(base64decode(self.input.meshstack_building_block_run_b64)).spec.behavior
    }
    command = <<EOT
      set -e
      echo $run_data
      if [ "$run_data" != "DESTROY" ]; then
        exit 0
      fi
      curl --fail-with-body -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${self.input.github_token}" \
        https://api.github.com/repos/${self.input.github_owner}/${self.input.github_repo}/actions/workflows/${self.input.workflow_destroy_file_name}/dispatches \
        -d "{\"ref\":\"${self.input.workflow_branch}\", \"inputs\": {\"bb-run\":\"${self.input.meshstack_building_block_run_b64}\"}}"
    EOT
  }
}