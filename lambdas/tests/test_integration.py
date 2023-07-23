import json
import os
import time

import boto3
from src.unsubscription_survey_saver import handler


def test_it_should_publish_to_sns_topic_and_reach_sqs():
    sqs = boto3.resource("sqs", endpoint_url=os.getenv("ENDPOINT_URL"), region_name="us-east-1")
    sqs = sqs.Queue(os.getenv("INTEGRATION_TEST_SQS"))
    sqs.purge()
    dynamodb = boto3.resource("dynamodb", endpoint_url=os.getenv("ENDPOINT_URL"), region_name="us-east-1")
    unsubscription_survey_table = dynamodb.Table(os.getenv("UNSUBSCRIPTION_SURVEY_TABLE"))

    handler(
        {"body": json.dumps({"user_id": "1", "answer_1": "hello"})}, {}
    )

    time.sleep(1)
    messages = sqs.receive_messages()
    print(messages[0].body)
    assert len(messages) > 0
    item = unsubscription_survey_table.get_item(Key={"userId": "1"})
    assert item["Item"] == {"userId": "1", "answer_1": "hello"}
