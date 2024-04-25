output "role_arn" {
  description = "The ARN of the role that Fullstory will use when loading data into Redshift."
  value       = aws_iam_role.main.arn
}
