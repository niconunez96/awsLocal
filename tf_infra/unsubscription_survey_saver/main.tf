resource "aws_sns_topic" "unsubscription_survey_submitted" {
  name = "unsubscription_survey_submitted"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../lambdas/src/subscription_bought_publisher.py"
  output_path = "subscription_bought_publisher.zip"
}

resource "aws_lambda_function" "test_function" {
  role          = aws_iam_role.iam_for_lambda.arn
  function_name = "test_function"
  handler       = "subscription_bought_publisher.handler"
  filename      = "subscription_bought_publisher.zip"
  runtime       = "python3.9"
  timeout       = 15

  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = {
    "env" = var.env
  }
}
