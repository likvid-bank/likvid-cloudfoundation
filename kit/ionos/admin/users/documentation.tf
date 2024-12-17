output "documentation_md" {
  value = <<EOF
# IONOS meshcloud Users

${join("\n", formatlist("- `%s`", [for u in var.users : u.email]))}

# IONOS API Users

${join("\n", formatlist("- `%s`", [for u in var.api_users : u.email]))}

EOF
}
