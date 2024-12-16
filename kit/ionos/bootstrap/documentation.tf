output "documentation_md" {
  value = <<EOF
# Automation User

Admin API user: `${var.email}`.

At this point, there is no distinction between a normal user and API user in IONOS. You can access the console using this user.
EOF
}
