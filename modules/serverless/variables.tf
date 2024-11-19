variable "prefix" {
  type        = string
  description = "The prefix to use for the resources created by this module."
  default     = "fullstory"
}

variable "role_name" {
  type        = string
  description = "The name of the role that Fullstory will assume to get credentials to the Redshift Serverless workgroup."
}

variable "workgroup_arn" {
  type        = string
  description = "The ARN of the Redshift Serverless workgroup."
}
