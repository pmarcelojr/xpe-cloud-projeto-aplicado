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

  filename = "lambdatrigger.zip"
  # source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  source_code_hash = filebase64sha256("../lambda/code/function.zip")
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.6"
  handler          = "lambda_function.lambda_handler"
  timeout          = 120
  memory_size      = 128
  description      = "Lambda function to trigger the mainframe data transfer"

  environment {
    variables = {
      "TBS0MH10" = "movimento_aplicacao_processado"
    }
  }
}
