resource "aws_sns_topic" "unsubscription_survey_submitted" {
  name = "unsubscription_survey_submitted"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../lambdas/src/unsubscription_survey_saver.py"
  output_path = "unsubscription_survey_saver.zip"
}

resource "aws_lambda_function" "test_function" {
  role          = aws_iam_role.iam_for_lambda.arn
  function_name = "test_function"
  handler       = "unsubscription_survey_saver.handler"
  filename      = "unsubscription_survey_saver.zip"
  runtime       = "python3.9"
  timeout       = 15

  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = {
    "env" = var.env
  }
  environment {
    variables = {
      UNSUBSCRIPTION_SURVEY_SUBMITTED = aws_sns_topic.unsubscription_survey_submitted.arn
      ENDPOINT_URL                    = var.env == "test" ? "http://localstack:4566" : ""
    }
  }
}
