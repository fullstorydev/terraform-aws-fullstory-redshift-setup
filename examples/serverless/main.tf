resource "aws_redshiftserverless_namespace" "main" {
  namespace_name        = "my-namespace"
  manage_admin_password = true
}

resource "aws_redshiftserverless_workgroup" "main" {
  namespace_name      = aws_redshiftserverless_namespace.main.id
  workgroup_name      = "my-workgroup"
  publicly_accessible = true # Your workgroup must be publicly accessible to allow Fullstory to access it.
  # This is the minimum capacity for a serverless workgroup. See https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-capacity.html for more details.
  base_capacity = 8 #
  subnet_ids = [
    "my-subnet-1",
    "my-subnet-2",
  ]
}

resource "aws_s3_bucket" "main" {
  bucket = "my-bucket"
}

module "fullstory_redshift_setup" {
  source = "fullstorydev/fullstory-redshift-setup/aws"

  vpc_id          = "my-vpc-id"
  workgroup_arn   = aws_redshiftserverless_workgroup.main.arn
  s3_bucket_name  = aws_s3_bucket.main.bucket
  fullstory_data_center = "NA1" # If your Fullstory account is hosted in the EU, set this to "EU1".
}

output "fullstory_host" {
  value       = aws_redshiftserverless_workgroup.main.endpoint
  description = "The host that should be entered when setting up this destination in Fullstory."
}

output "fullstory_port" {
  value       = aws_redshiftserverless_workgroup.main.port
  description = "The host that should be entered when setting up this destination in Fullstory."
}

output "fullstory_role_arn" {
  value       = module.fullstory_redshift_setup.role_arn
  description = "The role ARN that should be entered when setting up this destination in Fullstory."
}

output "fullstory_database" {
  value       = aws_redshiftserverless_namespace.main.db_name
  description = "The database name that Fullstory will connect to."
}

output "fullstory_workgroup" {
  value       = aws_redshiftserverless_workgroup.main.id
  description = "The workgroup identifier of the Redshift Serverless cluster."
}

output "fullstory_s3_bucket_name" {
  value       = aws_s3_bucket.main.bucket
  description = "The name of the S3 bucket that Fullstory will use to store bundles."
}
