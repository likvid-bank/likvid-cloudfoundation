# Use this IP to create your DNS A records.
# After first apply: terragrunt output haproxy_lb_ip
output "haproxy_lb_ip" {
  description = "External IP of the HAProxy LoadBalancer service. Point your DNS A record here before TLS provisioning can complete."
  value       = data.kubernetes_service_v1.haproxy_controller.status[0].load_balancer[0].ingress[0].ip
}
