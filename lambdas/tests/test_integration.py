import json
import os
import time

import boto3
from aws_lambda_powertools.utilities.data_classes import APIGatewayProxyEvent
from src.unsubscription_survey_saver import handler


def test_it_should_publish_to_sns_topic_and_reach_sqs():
    print("SQS", os.getenv("INTEGRATION_TEST_SQS"))
    print("URL", os.getenv("ENDPOINT_URL"))
    sqs = boto3.resource("sqs", endpoint_url=os.getenv("ENDPOINT_URL"), region_name="us-east-1")
    sqs = sqs.Queue(os.getenv("INTEGRATION_TEST_SQS"))
    sqs.purge()

    handler(
        APIGatewayProxyEvent({"body": json.dumps({"id": "1"}), "method": "GET"}), {}
    )

    time.sleep(1)
    messages = sqs.receive_messages()
    print(messages[0].body)
    assert len(messages) > 0
