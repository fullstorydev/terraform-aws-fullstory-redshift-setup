mock_provider "aws" {}

run "valid_serverless_minimal_details" {
  command = plan

  variables {
    vpc_id = "my-vpc"
    workgroup_arn = "workgroup_arn"
    s3_bucket_name = "my-bucket"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.allow_fullstory_ips_0.cidr_ipv4 == "8.35.195.0/29"
    error_message = "default cidr block is wrong"
  }
  assert {
    condition = jsondecode(aws_iam_role.main.assume_role_policy).Statement[0].Condition.StringEquals["accounts.google.com:aud"] == "116984388253902328461"
    error_message = "default oauth id is wrong"
  }
}
