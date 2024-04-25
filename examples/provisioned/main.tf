resource "aws_redshift_cluster" "main" {
  cluster_identifier     = "mycluster"
  database_name          = "mydatabase"
  master_username        = "mysuperuser"
  node_type              = "dc1.large"
  cluster_type           = "single-node"
  manage_master_password = true
}

resource "aws_s3_bucket" "main" {
  bucket = "my-bucket"
}

module "fullstory_redshift_setup" {
  source = "fullstorydev/fullstory-redshift-setup/aws"

  vpc_id                = "my-vpc-id"
  database_arn          = "arn:aws:redshift:${local.region}:${local.account_id}:dbname:${aws_redshift_cluster.main.cluster_identifier}/${aws_redshift_cluster.main.database_name}"
  cluster_identifier    = aws_redshift_cluster.main.cluster_identifier
  port                  = aws_redshift_cluster.main.port
  s3_bucket_name        = aws_s3_bucket.main.bucket
  fullstory_data_center = "NA1" # If your Fullstory account is hosted in the EU, set this to "EU1".
}

output "fullstory_host" {
  value       = aws_redshift_cluster.main.dns_name
  description = "The host that should be entered when setting up this destination in Fullstory."
}

output "fullstory_port" {
  value       = aws_redshift_cluster.main.port
  description = "The host that should be entered when setting up this destination in Fullstory."
}

output "fullstory_role_arn" {
  value       = module.fullstory_redshift_setup.role_arn
  description = "The role ARN that should be entered when setting up this destination in Fullstory."
}

output "fullstory_database" {
  value       = aws_redshift_cluster.main.database_name
  description = "The database name that Fullstory will connect to."
}

output "fullstory_cluster_identifier" {
  value       = aws_redshift_cluster.main.cluster_identifier
  description = "The identifier of the Redshift cluster."
}

output "fullstory_s3_bucket_name" {
  value       = aws_s3_bucket.main.bucket
  description = "The name of the S3 bucket that Fullstory will use to store bundles."
}
