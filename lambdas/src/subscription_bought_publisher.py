import json
import os

import boto3
from aws_lambda_powertools.utilities.data_classes import (
    APIGatewayProxyEvent,
    event_source,
)

session = boto3.Session()
sns_resource = session.resource(
    "sns",
    region_name="us-east-1",
    endpoint_url="http://" + os.getenv("LOCALSTACK_HOSTNAME", "localhost") + ":4566",
)

topic = sns_resource.Topic(os.getenv("TOPIC_ARN", "arn:aws:sns:us-east-1:000000000000:InfraTopic"))


@event_source(data_class=APIGatewayProxyEvent)
def handler(event: APIGatewayProxyEvent, context):
    topic.publish(Message=json.dumps({"id": "1", "metadata": {"correlation_id": ""}}))
    return {"statusCode": 200, "body": "Hello world"}
