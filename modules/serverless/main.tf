resource "aws_iam_policy" "main" {
  name        = "${var.prefix}_get_credentials"
  path        = "/"
  description = "Allows Fullstory to get credentials to the Redshift Serverless workgroup"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "redshift-serverless:GetCredentials",
        ]
        Effect   = "Allow"
        Resource = var.workgroup_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = var.role_name
  policy_arn = aws_iam_policy.main.arn
}
