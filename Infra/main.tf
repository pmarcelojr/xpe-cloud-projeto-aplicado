# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  #backend "s3" {
  #  bucket         = "kyler-github-actions-demo-terraform-tfstate"
  #  key            = "terraform.tfstate"
  #  region         = "us-east-1"
  #  dynamodb_table = "aws-locks"
  #  encrypt        = true
  #}
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "sa-east-1"
  version = "~> 2.36.0"
}

# # Build the VPC
# resource "aws_vpc" "vpc" {
#   cidr_block       = "10.1.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name      = "Vpc"
#     Terraform = "true"
#   }
# }

# # Build route table 1
# resource "aws_route_table" "route_table1" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name      = "RouteTable1"
#     Terraform = "true"
#   }
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../app/lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs8.10"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
