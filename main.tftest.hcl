mock_provider "aws" {}

run "valid_serverless_minimal_details" {
  command = plan

  variables {
    prefix         = "my-prefix"
    vpc_id         = "my-vpc"
    workgroup_arn  = "workgroup_arn"
    s3_bucket_name = "my-bucket"
    is_serverless  = true
  }

  assert {
    condition     = aws_iam_role.main.name == "my_prefix_redshift_setup"
    error_message = "role name is wrong"
  }

  assert {
    condition     = jsondecode(aws_iam_role.main.assume_role_policy).Statement[0].Condition.StringEquals["accounts.google.com:aud"] == "116984388253902328461"
    error_message = "default oauth id is wrong"
  }
}
