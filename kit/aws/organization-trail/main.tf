data "aws_caller_identity" "org_mgmt" {
  provider = aws.org_mgmt
}

data "aws_caller_identity" "audit" {
  provider = aws.audit
}

data "aws_partition" "current" {}


# SSO read-only access to the audit account for auditors
data "aws_ssoadmin_instances" "sso" {
  provider = aws.org_mgmt
}

data "aws_ssoadmin_permission_set" "readonly" {
  provider     = aws.org_mgmt
  instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  name         = "AWSReadOnlyAccess"
}

data "aws_identitystore_user" "auditors" {
  provider = aws.org_mgmt
  for_each = toset(var.auditors)

  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "aws_ssoadmin_account_assignment" "auditors" {
  provider = aws.org_mgmt
  for_each = toset(var.auditors)

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  permission_set_arn = data.aws_ssoadmin_permission_set.readonly.arn

  principal_id   = data.aws_identitystore_user.auditors[each.key].user_id
  principal_type = "USER"

  target_id   = data.aws_caller_identity.audit.account_id
  target_type = "AWS_ACCOUNT"
}


# S3 Bucket im Audit Account
resource "aws_s3_bucket" "cloudtrail" {
  provider = aws.audit
  bucket   = var.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  provider = aws.audit
  bucket   = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  provider                = aws.audit
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  provider = aws.audit
  bucket   = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.cloudtrail.id}"
      },
      {
        Sid       = "AWSCloudTrailWrite",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.cloudtrail.id}/AWSLogs/*/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


# CloudTrail im Org Management Account
resource "aws_cloudtrail" "organization" {
  provider                      = aws.org_mgmt
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  is_organization_trail         = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  include_global_service_events = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
