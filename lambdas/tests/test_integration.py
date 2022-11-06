from src.subscription_bought_publisher import handler
from aws_lambda_powertools.utilities.data_classes import APIGatewayProxyEvent
import json
import boto3


def test_it_should_publish_to_sns_topic_and_reach_sqs():
    handler(
        APIGatewayProxyEvent({"body": json.dumps({"id": "1"}), "method": "GET"}), {}
    )

    sqs = boto3.resource("sqs", endpoint_url="http://localhost:4566")
    sqs = sqs.Queue("http://localhost:4566/000000000000/InfraQueue")
    messages = sqs.receive_messages()

    print(messages[0].body)
    assert len(messages) > 0
