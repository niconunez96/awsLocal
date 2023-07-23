output "integration_test_sqs" {
  value = aws_sqs_queue.integration_test_queue[0].url
}

output "unsubscription_survey_submitted_topic" {
  value = aws_sns_topic.unsubscription_survey_submitted.arn
}

output "unsubscription_survey_table" {
  value = aws_dynamodb_table.unsubscription_survey.name
}

output "unsubscription_survey_lambda_name" {
  value = aws_lambda_function.test_function.function_name
}

output "unsubscription_survey_lambda_arn" {
  value = aws_lambda_function.test_function.invoke_arn
}
