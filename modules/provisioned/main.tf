resource "aws_iam_policy" "main" {
  name        = "fullstory_get_credentials"
  path        = "/"
  description = "Allows Fullstory to get credentials to the Redshift Serverless workgroup"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "redshift:GetClusterCredentialsWithIAM",
        ]
        Effect   = "Allow"
        Resource = var.database_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = var.role_name
  policy_arn = aws_iam_policy.main.arn
}

# We need to look up the ARN for the role name
data "aws_iam_role" "main" {
  name = var.role_name
}

resource "aws_redshift_cluster_iam_roles" "main" {
  cluster_identifier = var.cluster_identifier
  iam_role_arns      = [data.aws_iam_role.main.arn]
}
