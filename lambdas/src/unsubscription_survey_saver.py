import json
import os

import boto3
# from aws_lambda_powertools.utilities.data_classes import (
#     APIGatewayProxyEvent,
#     event_source,
# )

session = boto3.Session()

if os.getenv("ENDPOINT_URL"):
    sns_resource = session.resource(
        "sns", endpoint_url=os.getenv("ENDPOINT_URL")
    )
else:
    sns_resource = session.resource("sns")

topic = sns_resource.Topic(str(os.getenv("UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC")))


# @event_source(data_class=APIGatewayProxyEvent)
def handler(event, context):
    response = topic.publish(Message=json.dumps({"id": "1", "metadata": {"correlation_id": ""}}))
    print(response)
    return {"statusCode": 200, "body": "Hello world"}
