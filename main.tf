locals {
  fullstory_google_audience = var.fullstory_google_audience != "" ? var.fullstory_google_audience : (var.fullstory_data_center == "EU1" ? "107589159240321051166" : "116984388253902328461")
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_iam_role" "main" {
  name = "${replace(var.prefix, "-", "_")}_redshift_setup"
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
            "accounts.google.com:aud" = local.fullstory_google_audience
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

resource "aws_s3_bucket_policy" "main" {
  bucket = var.s3_bucket_name

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
          "arn:aws:s3:::${var.s3_bucket_name}/*",
          "arn:aws:s3:::${var.s3_bucket_name}",
        ]
      },
    ]
  })
}

module "redshift_serverless" {
  count  = var.is_serverless ? 1 : 0
  source = "./modules/serverless"

  prefix        = var.prefix
  workgroup_arn = var.workgroup_arn
  role_name     = aws_iam_role.main.name
}

module "redshift_provisioned" {
  count              = var.is_serverless ? 0 : 1
  source             = "./modules/provisioned"
  cluster_identifier = var.cluster_identifier
  database_arn       = var.database_arn
  prefix             = var.prefix
  role_name          = aws_iam_role.main.name
}
