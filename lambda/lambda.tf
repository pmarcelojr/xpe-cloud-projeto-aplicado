/* 
Arquive the script
*/
# data "archive_file" "python_lambda_package" {
#   type        = "zip"
#   source_file = "./code/function.zip"
#   # output_path = "lambdatrigger.zip"
# }

/*
  Create the lamda function
*/
resource "aws_lambda_function" "lambda_function_trigger" {
  function_name = "cargamf-trigger-lambda-banco-do-povo"

  filename = "../lambda/code/function.zip"
  # source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  source_code_hash = filebase64sha256("../lambda/code/function.zip")
  role             = "arn:aws:iam::890006230292:role/lambda-trigger-mf-banco-do-povo-role"
  runtime          = "python3.9"
  handler          = "function.lambda_function.lambda_handler"
  timeout          = 120
  memory_size      = 128
  description      = "Lambda function to trigger the mainframe data transfer"

  environment {
    variables = {
      "TBS0MH10" = "movimento_aplicacao_processado"
    }
  }

  depends_on = [aws_iam_role.function_role]
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_trigger.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_iam_role" "function_role" {
  name = "lambda-trigger-mf-banco-do-povo-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# resource "aws_iam_policy" "function_logging_policy" {
#   name = "cargamf-trigger-lambda-logging-policy"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         Action : [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Effect : "Allow",
#         Resource : "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.function_role.id
  policy_arn = "arn:aws:iam::890006230292:policy/cargamf-trigger-lambda-logging-policy"
}
