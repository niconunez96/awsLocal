import * as cdk from "aws-cdk-lib";
import * as dynamodb from "aws-cdk-lib/aws-dynamodb";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as sns from "aws-cdk-lib/aws-sns";
import * as sqs from "aws-cdk-lib/aws-sqs";
import { Construct } from "constructs";
import { Stage } from "../types";

export class UnsubscriptionSurveySaver extends Construct {
  public lambda: lambda.Function;
  private topic: sns.Topic;

  constructor(scope: Construct, id: string, stage: Stage) {
    super(scope, id);

    this.topic = new sns.Topic(this, "unsubscription_survey_submitted", {
      displayName: "Unsubscription Survey Submitted",
    });
    const unsubscriptionSurveyTable = new dynamodb.Table(
      this,
      "UnsubscriptionSurvey",
      {
        partitionKey: {
          name: "userId",
          type: dynamodb.AttributeType.STRING,
        },
      }
    );

    this.lambda = new lambda.Function(this, "LambdaPublisher", {
      description: "Lambda that publishes to a SNS",
      runtime: lambda.Runtime.PYTHON_3_9,
      code: lambda.Code.fromAsset("../lambdas/src"),
      handler: "unsubscription_survey_saver.handler",
      environment: {
        UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC: this.topic.topicArn,
        UNSUBSCRIPTION_SURVEY_TABLE: unsubscriptionSurveyTable.tableName,
        ENDPOINT_URL: stage === "test" ? "http://localstack:4566" : "",
      },
    });
    this.topic.grantPublish(this.lambda.role!!);
    unsubscriptionSurveyTable.grantWriteData(this.lambda.role!!);

    if (stage === "test") {
      const integrationTestQueue = new sqs.Queue(
        this,
        "integration_test_queue",
        {
          queueName: "integration_test_queue",
          visibilityTimeout: cdk.Duration.seconds(300),
        }
      );
      new sns.Subscription(this, "TestQueue", {
        topic: this.topic,
        protocol: sns.SubscriptionProtocol.SQS,
        endpoint: integrationTestQueue.queueArn,
      });
      new cdk.CfnOutput(this, "INTEGRATION_TEST_SQS", {
        value: integrationTestQueue.queueUrl,
      }).overrideLogicalId("INTEGRATION_TEST_SQS");
    }

    new cdk.CfnOutput(this, "UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC", {
      value: this.topic.topicArn,
    }).overrideLogicalId("UNSUBSCRIPTION_SURVEY_SUBMITTED_TOPIC");
    new cdk.CfnOutput(this, "UNSUBSCRIPTION_SURVEY_TABLE", {
      value: unsubscriptionSurveyTable.tableName,
    }).overrideLogicalId("UNSUBSCRIPTION_SURVEY_TABLE");
  }
}
