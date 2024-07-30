resource "aws_iam_user" "main" {
  name = var.user_name
  path = "/${var.user_path}/"
}
