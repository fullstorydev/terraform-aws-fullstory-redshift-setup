variable "database_arn" {
  type        = string
  description = "The ARN of the database within Redshift cluster. Required if you are using Redshift provisioned. This is not the cluster ARN, see https://docs.aws.amazon.com/redshift/latest/mgmt/generating-iam-credentials-role-permissions.html for more information."
  default     = ""
  validation {
    condition     = can(regex("arn:aws:redshift:[a-z0-9-]+:.*:dbname:[a-z0-9-]+/.+", var.database_arn))
    error_message = "The cluster ARN must include 'dbname' name. Ex. arn:aws:redshift:us-west-2:123456789012:dbname:my-cluster/my-database"
  }
}

variable "cluster_identifier" {
  type        = string
  description = "The identifier of the Redshift cluster. Required if you are using Redshift provisioned."
  default     = ""
}

variable "fullstory_cidr_ipv4" {
  type        = string
  description = "The CIDR block that Fullstory will use to connect to the Redshift cluster."
  default     = ""
}

variable "fullstory_google_audience" {
  type        = string
  description = "The Google audience identifier that Fullstory will use to assume the role in order to call AWS APIs"
  default     = ""
}

variable "fullstory_realm" {
  type        = string
  description = "The realm where your Fullstory account is hosted. Either 'NA1' or 'EU1'."
  validation {
    condition     = var.fullstory_realm == "NA1" || var.fullstory_realm == "EU1"
    error_message = "The realm must be either 'NA1' or 'EU1'."
  }
}

variable "port" {
  type        = number
  description = "The port number where the Redshift cluster is listening."
  default     = 5439
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket where the Fullstory bundles are stored."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the Redshift cluster or Redshift Serverless workgroup is deployed."
}

variable "workgroup_arn" {
  type        = string
  description = "The ARN of the Redshift Serverless workgroup. Required if you are using Redshift Serverless."
  default     = ""
}

