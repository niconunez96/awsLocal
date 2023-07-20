output "API_GATEWAY" {
  value = module.unsubscription_survey_saver.api_gateway
}

output "INTEGRATION_TEST_SQS" {
  value = module.unsubscription_survey_saver.integration_test_sqs
}

output "UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC" {
  value = module.unsubscription_survey_saver.unsubscription_survey_submitted_topic
}
