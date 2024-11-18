<a href="https://fullstory.com"><img src="https://github.com/fullstorydev/terraform-aws-fullstory-redshift-setup/blob/main/assets/fs-logo.png?raw=true"></a>

# terraform-aws-fullstory-redshift-setup

[![GitHub release](https://img.shields.io/github/release/fullstorydev/terraform-aws-fullstory-redshift-setup.svg)](https://github.com/fullstorydev/terraform-aws-fullstory-redshift-setup/releases/)

This module creates all the proper policies, roles and S3 buckets so that Fullstory can connect to the Redshift Cluster or Workgroup and load data. For more information checkout [this KB article](https://help.fullstory.com/hc/en-us/articles/18791516308887-Amazon-Redshift).

**This module does not** create the permissions in your database that are required for Fullstory to create schemas. See [this guide](https://help.fullstory.com/hc/en-us/articles/18791516308887-Amazon-Redshift#h_01HNGMBXC344AM02MR35QFZJ2T) for instructions on how to grant your IAM role the correct permissions on your database objects.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The identifier of the Redshift cluster. Required if you are using Redshift provisioned. | `string` | `""` | no |
| <a name="input_database_arn"></a> [database\_arn](#input\_database\_arn) | The ARN of the database within Redshift cluster. Required if you are using Redshift provisioned. This is not the cluster ARN, see https://docs.aws.amazon.com/redshift/latest/mgmt/generating-iam-credentials-role-permissions.html for more information. | `string` | `""` | no |
| <a name="input_fullstory_cidr_ipv4s"></a> [fullstory\_cidr\_ipv4s](#input\_fullstory\_cidr\_ipv4s) | The CIDR block that Fullstory will use to connect to the Redshift cluster. | `list(string)` | `[]` | no |
| <a name="input_fullstory_data_center"></a> [fullstory\_data\_center](#input\_fullstory\_data\_center) | The data center where your Fullstory account is hosted. Either 'NA1' or 'EU1'. See https://help.fullstory.com/hc/en-us/articles/8901113940375-Fullstory-Data-Residency for more information. | `string` | `"NA1"` | no |
| <a name="input_fullstory_google_audience"></a> [fullstory\_google\_audience](#input\_fullstory\_google\_audience) | The Google audience identifier that Fullstory will use to assume the role in order to call AWS APIs | `string` | `""` | no |
| <a name="input_is_serverless"></a> [is\_serverless](#input\_is\_serverless) | Whether the Redshift cluster is serverless or not. If true, workgroup\_arn is required. If false, database\_arn is required. | `bool` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port number where the Redshift cluster is listening. | `number` | `5439` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket where the Fullstory bundles are stored. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID where the Redshift cluster or Redshift Serverless workgroup is deployed. | `string` | n/a | yes |
| <a name="input_workgroup_arn"></a> [workgroup\_arn](#input\_workgroup\_arn) | The ARN of the Redshift Serverless workgroup. Required if you are using Redshift Serverless. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the role that Fullstory will use when loading data into Redshift. |

## Usage

### Redshift Serverless
```hcl
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
```

### Redshift Provisioned
```hcl
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
```
<!-- END_TF_DOCS -->

## Obtaining the configuration fields

This module outputs some of the fields required by Fullstory to setup your Redshift connection. In order to view the outputs of this module, the outputs must also be included in your root module, then accessed via the Terraform CLI:

```bash
terraform output <name of your output varible > | pbcopy
```

Alternatively, you can view all the configuration information inside the AWS console.

## Contributing

See [CONTRIBUTING.md](https://github.com/fullstorydev/terraform-aws-fullstory-aws-setup/blob/main/.github/CONTRIBUTING.md) for best practices and instructions on setting up your dev environment.
