/*
  Create user role for lambda function
*/
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-trigger-mf-banco-do-povo-v3"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}
