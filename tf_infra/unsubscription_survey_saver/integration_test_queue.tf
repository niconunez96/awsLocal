resource "aws_sqs_queue" "integration_test_queue" {
  name                      = "integration_test_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  count = var.env == "test" ? 1 : 0

  tags = {
    Environment = var.env
  }
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.unsubscription_survey_submitted.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.integration_test_queue[0].arn
}
