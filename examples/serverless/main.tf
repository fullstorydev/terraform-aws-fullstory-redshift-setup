resource "aws_redshiftserverless_namespace" "main" {
  namespace_name        = "my-namespace"
  manage_admin_password = true
}

resource "aws_redshiftserverless_workgroup" "main" {
  namespace_name      = resource.aws_redshiftserverless_namespace.main.id
  workgroup_name      = "my-workgroup"
  publicly_accessible = true # Your workgroup must be publicly accessible to allow Fullstory to access it.
  # This is the minimum capacity for a serverless workgroup. See https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-capacity.html for more details.
  base_capacity = 8 #
  subnet_ids = [
    "my-subnet-1",
    "my-subnet-2",
  ]
}

module "fullstory_redshift_setup" {
  source = "fullstorydev/fullstory-redshift-setup/aws"

  vpc_id          = "my-vpc-id"
  workgroup_arn   = aws_redshiftserverless_workgroup.main.arn
  fullstory_realm = "NA1" # If your Fullstory account is hosted in the EU, set this to "EU1".
}

output "fullstory_s3_bucket_name" {
  value       = module.fullstory_redshift_setup.s3_bucket_name
  description = "The name of the bucket that should be entered when setting up this destination in Fullstory."
}

output "fullstory_role_arn" {
  value       = module.fullstory_redshift_setup.role_arn
  description = "The role ARN that should be entered when setting up this destination in Fullstory."
}
