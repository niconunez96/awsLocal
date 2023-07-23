resource "aws_sqs_queue" "integration_test_queue" {
  name                      = "integration_test_queue"

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
