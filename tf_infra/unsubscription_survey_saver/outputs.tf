output "api_gateway" {
  value = aws_api_gateway_deployment.tf_rest_api.invoke_url
}

output "integration_test_sqs" {
  value = aws_sqs_queue.integration_test_queue[0].url
}

output "unsubscription_survey_submitted_topic" {
  value = aws_sns_topic.unsubscription_survey_submitted.arn
}

output "unsubscription_survey_table" {
  value = aws_dynamodb_table.unsubscription_survey.name
}
