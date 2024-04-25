output "s3_bucket_name" {
  description = "The name of the bucket that Fullstory will use to store Redshift bundles for loading."
  value       = aws_s3_bucket.main.bucket
}

output "role_arn" {
  description = "The ARN of the role that Fullstory will use when loading data into Redshift."
  value       = aws_iam_role.main.arn
}
