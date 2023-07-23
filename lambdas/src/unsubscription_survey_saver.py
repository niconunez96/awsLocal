import json
import os

import boto3

# from aws_lambda_powertools.utilities.data_classes import (
#     APIGatewayProxyEvent,
#     event_source,
# )

session = boto3.Session()

dynamo = session.resource("dynamodb", endpoint_url=os.getenv("ENDPOINT_URL"))
sns_resource = session.resource("sns", endpoint_url=os.getenv("ENDPOINT_URL"))
topic = sns_resource.Topic(str(os.getenv("UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC")))


# @event_source(data_class=APIGatewayProxyEvent)
def handler(event, context):
    try:
        table = dynamo.Table(str(os.getenv("UNSUBSCRIPTION_SURVEY_TABLE")))
        body = json.loads(event["body"])
        item = {
            "userId": body["user_id"],
            "answer_1": body["answer_1"],
        }
        table.put_item(Item=item)
        topic.publish(Message=json.dumps({"item": item, "metadata": {"correlation_id": ""}}))
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(item),
        }
    except Exception as e:
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": str(e)})
        }
