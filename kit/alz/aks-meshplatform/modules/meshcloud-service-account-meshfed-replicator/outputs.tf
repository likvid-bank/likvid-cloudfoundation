data "kubernetes_secret" "meshfed_service_secret" {
  metadata {
    name      = kubernetes_service_account.meshfed_service.default_secret_name
    namespace = kubernetes_service_account.meshfed_service.metadata.0.namespace
  }
  depends_on = [
    kubernetes_service_account.meshfed_service
  ]
}

output "meshfed_replicator_token" {
  sensitive = true
  value     = data.kubernetes_secret.meshfed_service_secret
}

output "token_replicator" {
  sensitive = true
  value     = data.kubernetes_secret.meshfed_service_secret.data["token"]
}

output "expose_token" {
  value = "Expose the token with: terraform output -json replocator_token "
}