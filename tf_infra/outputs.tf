output "API_GATEWAY" {
  value = "https://${aws_api_gateway_rest_api.tf_rest_api.id}.execute-api.localhost.localstack.cloud:4566/prod/"
}

output "INTEGRATION_TEST_SQS" {
  value = module.unsubscription_survey_saver.integration_test_sqs
}

output "UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC" {
  value = module.unsubscription_survey_saver.unsubscription_survey_submitted_topic
}

output "UNSUBSCRIPTION_SURVEY_TABLE" {
  value = module.unsubscription_survey_saver.unsubscription_survey_table
}
