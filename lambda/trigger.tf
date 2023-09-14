/*
  Create cron event with bucket
*/

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFrombucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::connect-mainframe-banco-do-povo"
}

resource "aws_s3_bucket_notification" "aws_lambda_trigger" {
  bucket = "connect-mainframe-banco-do-povo"

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "datatransfer/"
    filter_suffix       = ".csv"
  }
}
