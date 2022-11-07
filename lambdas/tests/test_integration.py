import json
import os

import boto3
from aws_lambda_powertools.utilities.data_classes import APIGatewayProxyEvent

from src.subscription_bought_publisher import handler


def test_it_should_publish_to_sns_topic_and_reach_sqs():
    handler(
        APIGatewayProxyEvent({"body": json.dumps({"id": "1"}), "method": "GET"}), {}
    )

    sqs = boto3.resource("sqs", endpoint_url=os.getenv("ENDPOINT_URL"))
    sqs = sqs.Queue(os.getenv("SQS_DOMAIN_QUEUE"))
    messages = sqs.receive_messages()

    print(messages[0].body)
    assert len(messages) > 0
