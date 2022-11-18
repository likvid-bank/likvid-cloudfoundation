data "kubernetes_secret" "meshfed_metering_secret" {
  metadata {
    name      = kubernetes_service_account.meshfed_metering.default_secret_name
    namespace = kubernetes_service_account.meshfed_metering.metadata.0.namespace
  }
  depends_on = [
    kubernetes_service_account.meshfed_metering
  ]
}

output "meshfed_metering_token" {
  sensitive = true
  value     = data.kubernetes_secret.meshfed_metering_secret
}

output "token_metering" {
  sensitive = true
  value     = data.kubernetes_secret.meshfed_metering_secret.data["token"]
}

output "expose_token" {
  value = "Expose the token with: terraform output -json metering_token "
}

