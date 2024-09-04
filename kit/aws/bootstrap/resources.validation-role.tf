#TODO: i dont have clue. This is for the whole organization. Deployed in ICF
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "allow_assume_validation_role_from_github" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    # todo: on the azure bootstrap kit we have this parameter configurable, should tie it all to a single source of truth
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo_full_name}:environment:${var.foundation}"
      ]
    }
  }
}

# todo: figure out non-root account access, i.e. will need additional permission to assume roles in other accounts
resource "aws_iam_role" "validation" {
  name        = "${var.foundation}-foundation-tf-validation"
  description = "Used by the cloudfoundation team to validate the deployment from github actions"

  assume_role_policy = data.aws_iam_policy_document.allow_assume_validation_role_from_github.json

  // todo: consider adopting a path for all our cloud foundation IAM stuff on AWS
  # with the path though, we have duplication between the role name and the path
  path = "/${var.foundation}-foundation/"
}

resource "aws_iam_role_policy_attachment" "validation_read_only" {
  role       = aws_iam_role.validation.id
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "allow_assume_validation_role_in_org" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"
    resources = [
      "arn:aws:iam::*:role/${var.validation_role_name}",
      "arn:aws:iam::${var.managment_account_id}:role/OrganizationAccountAccessRole"
    ]
  }
}

resource "aws_iam_policy" "assume_validation_role" {
  description = "Grants permission to assume validation role on any account within the organization"
  name        = "${var.foundation}-foundation-assume-validation"
  policy      = data.aws_iam_policy_document.allow_assume_validation_role_in_org.json
}

resource "aws_iam_role_policy_attachment" "validation_assume_validation_role_in_org" {
  role       = aws_iam_role.validation.id
  policy_arn = aws_iam_policy.assume_validation_role.arn
}
