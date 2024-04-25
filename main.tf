locals {
  fullstory_cidr_ipv4       = var.fullstory_realm == "EU1" ? "34.89.210.80/29" : "8.35.195.0/29"
  fullstory_google_audience = var.fullstory_realm == "EU1" ? "107589159240321051166" : "116984388253902328461"
  is_serverless             = var.workgroup_arn != ""
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_security_group" "allow_fullstory_ips" {
  name        = "fullstory-allow-fullstory-ips"
  description = "Allow Redshift traffic from Fullstory IPs"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_fullstory_ips_0" {
  security_group_id = aws_security_group.allow_fullstory_ips.id
  cidr_ipv4         = local.fullstory_cidr_ipv4
  ip_protocol       = "tcp"

  # https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-connecting.html
  from_port = 5431
  to_port   = 5455
}

resource "aws_vpc_security_group_ingress_rule" "allow_fullstory_ips_1" {
  security_group_id = aws_security_group.allow_fullstory_ips.id
  cidr_ipv4         = local.fullstory_cidr_ipv4
  ip_protocol       = "tcp"

  # https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-connecting.html
  from_port = 8191
  to_port   = 8215
}

resource "aws_iam_role" "main" {
  name = "fullstory_redshift_setup"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "accounts.google.com"
        },
        Condition = {
          StringEquals = {
            # "accounts.google.com:aud" = local.fullstory_google_audience
            "accounts.google.com:aud" = "116623030858962667063"
          }
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_s3_bucket" "main" {
  # We use bucket prefix here so that we don't run into uniqueness issues.
  bucket_prefix = "fullstory-redshift-setup-"
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:DeleteObject"
        ]
        Principal = {
          AWS = aws_iam_role.main.arn
        }
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.main.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.main.bucket}",
        ]
      },
    ]
  })
}

module "redshift_serverless" {
  count         = local.is_serverless ? 1 : 0
  source        = "./modules/serverless"
  workgroup_arn = var.workgroup_arn
  role_name     = aws_iam_role.main.name
}

module "redshift_provisioned" {
  count              = local.is_serverless ? 0 : 1
  source             = "./modules/provisioned"
  cluster_identifier = var.cluster_identifier
  database_arn       = var.database_arn
  role_name          = aws_iam_role.main.name
}
