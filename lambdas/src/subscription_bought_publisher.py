import json
import os

import boto3
from aws_lambda_powertools.utilities.data_classes import (
    APIGatewayProxyEvent,
    event_source,
)

session = boto3.Session()
print("ENDPOINT URL: ", os.getenv("ENDPOINT_URL"))

if os.getenv("ENDPOINT_URL"):
    sns_resource = session.resource(
        "sns", region_name="us-east-1", endpoint_url=os.getenv("ENDPOINT_URL")
    )
else:
    sns_resource = session.resource(
        "sns",
        region_name="us-east-1",
    )

topic = sns_resource.Topic(
    os.getenv(
        "SUBSCRIPTION_BOUGHT_TOPIC_ARN",
        "arn:aws:sns:us-east-1:000000000000:SubscriptionBought",
    )
)


@event_source(data_class=APIGatewayProxyEvent)
def handler(event: APIGatewayProxyEvent, context):
    topic.publish(Message=json.dumps({"id": "1", "metadata": {"correlation_id": ""}}))
    return {"statusCode": 200, "body": "Hello world"}
