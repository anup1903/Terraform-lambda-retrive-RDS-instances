provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["/Users/Anup/.aws/credentials"]
}

resource "aws_dynamodb_table" "rds_instances" {
  name         = "RDSInstancesTable"
  billing_mode = "PROVISIONED"
  hash_key     = "Endpoint"
  range_key    = "InstanceType"

  attribute {
    name = "Endpoint"
    type = "S"
  }

  attribute {
    name = "InstanceType"
    type = "S"
  }

  tags = {
    Name        = "Demo dynamodb table"
    Environment = "Testing"
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for DynamoDB access

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb_policy"
  description = "Policy for DynamoDB access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": aws_dynamodb_table.rds_instances.arn
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "dynamodb_policy_attachment" {
  name       = "dynamodb_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# Generates an archive from content, a file, or a directory of files.

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/get_rds_endpoints/"
  output_path = "${path.module}/get_rds_endpoints/get_rds_endpoints.zip"
}

resource "aws_lambda_function" "get_rds_endpoints" {
  filename      = "${path.module}/get_rds_endpoints/get_rds_endpoints.zip"
  function_name = "GetRDSEndpoints"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "get_rds_endpoints.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.rds_instances.name
    }
  }

  timeout = 30
}
