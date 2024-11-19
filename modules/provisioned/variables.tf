variable "cluster_identifier" {
  type        = string
  description = "The identifier of the Redshift cluster"
}

variable "database_arn" {
  type        = string
  description = "The ARN of the database within the Redshift cluster."
  validation {
    condition     = can(regex("arn:aws:redshift:[a-z0-9-]+:.*:dbname:[a-z0-9-]+/.+", var.database_arn))
    error_message = "The cluster ARN must include 'dbname' name. Ex. arn:aws:redshift:us-west-2:123456789012:dbname:my-cluster/my-database"
  }
}

variable "prefix" {
  type        = string
  description = "The prefix to use for the resources created by this module."
  default     = "fullstory"
}

variable "role_name" {
  type        = string
  description = "The name of the role that Fullstory will assume to get credentials to the Redshift cluster."
}
