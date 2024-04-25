resource "aws_redshift_cluster" "main" {
  cluster_identifier = "mycluster"
  database_name      = "mydatabase"
  master_username    = "mysuperuser"
  node_type          = "dc1.large"
  cluster_type       = "single-node"

  manage_master_password = true
}

module "fullstory_redshift_setup" {
  source = "fullstorydev/fullstory-redshift-setup/aws"

  vpc_id             = "my-vpc-id"
  database_arn       = "arn:aws:redshift:${local.region}:${local.account_id}:dbname:${aws_redshift_cluster.main.cluster_identifier}/${aws_redshift_cluster.main.database_name}"
  cluster_identifier = aws_redshift_cluster.main.cluster_identifier
  port               = aws_redshift_cluster.main.port
  fullstory_realm    = "NA1" # If your Fullstory account is hosted in the EU, set this to "EU1".

}

output "fullstory_role_arn" {
  value       = module.fullstory_redshift_setup.role_arn
  description = "The role ARN that should be entered when setting up this destination in Fullstory."
}

