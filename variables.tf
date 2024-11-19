variable "database_arn" {
  type        = string
  description = "The ARN of the database within Redshift cluster. Required if you are using Redshift provisioned. This is not the cluster ARN, see https://docs.aws.amazon.com/redshift/latest/mgmt/generating-iam-credentials-role-permissions.html for more information."
  default     = ""
  validation {
    condition     = var.database_arn == "" || can(regex("arn:aws:redshift:[a-z0-9-]+:.*:dbname:[a-z0-9-]+/.+", var.database_arn))
    error_message = "The cluster ARN must include 'dbname' name. Ex. arn:aws:redshift:us-west-2:123456789012:dbname:my-cluster/my-database"
  }
}

variable "cluster_identifier" {
  type        = string
  description = "The identifier of the Redshift cluster. Required if you are using Redshift provisioned."
  default     = ""
}

variable "fullstory_cidr_ipv4s" {
  type        = list(string)
  description = "The CIDR block that Fullstory will use to connect to the Redshift cluster."
  default     = []
}

variable "fullstory_google_audience" {
  type        = string
  description = "The Google audience identifier that Fullstory will use to assume the role in order to call AWS APIs"
  default     = ""
}

variable "fullstory_data_center" {
  type        = string
  description = "The data center where your Fullstory account is hosted. Either 'NA1' or 'EU1'. See https://help.fullstory.com/hc/en-us/articles/8901113940375-Fullstory-Data-Residency for more information."
  default     = "NA1"
  validation {
    condition     = var.fullstory_data_center == "NA1" || var.fullstory_data_center == "EU1"
    error_message = "The data center must be either 'NA1' or 'EU1'."
  }
}

variable "is_serverless" {
  type        = bool
  description = "Whether the Redshift cluster is serverless or not. If true, workgroup_arn is required. If false, database_arn is required."
}

variable "port" {
  type        = number
  description = "The port number where the Redshift cluster is listening."
  default     = 5439
}

variable "prefix" {
  type        = string
  description = "The prefix to use for the resources created by this module."
  default     = "fullstory"
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

