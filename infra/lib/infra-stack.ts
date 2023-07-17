import * as cdk from "aws-cdk-lib";
import * as apiGateway from "aws-cdk-lib/aws-apigateway";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as sns from "aws-cdk-lib/aws-sns";
import * as sqs from "aws-cdk-lib/aws-sqs";
import { Construct } from "constructs";

export class InfraStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const integrationTestQueue = new sqs.Queue(this, "integration_test_queue", {
      queueName: "integration_test_queue",
      visibilityTimeout: cdk.Duration.seconds(300),
    });
    const unsubscriptionSurveySaverTopic = new sns.Topic(
      this,
      "unsubscription_survey_submitted",
      {
        topicName: "unsubscription_survey_submitted",
      }
    );
    new sns.Subscription(this, "UnsubscriptionSurveyTestSubscription", {
      topic: unsubscriptionSurveySaverTopic,
      protocol: sns.SubscriptionProtocol.SQS,
      endpoint: integrationTestQueue.queueArn,
    });

    const lambdaPublisher = new lambda.Function(this, "LambdaPublisher", {
      functionName: "LambdaPublisher",
      description: "Lambda that publishes to a SNS",
      runtime: lambda.Runtime.PYTHON_3_9,
      code: lambda.Code.fromAsset("../lambdas/src"),
      handler: "unsubscription_survey_saver.handler",
      environment: {
        UNSUBSCRIPTION_SURVEY_SUBMITTED: unsubscriptionSurveySaverTopic.topicArn,
        ENDPOINT_URL: "http://localstack:4566",
      },
    });
    unsubscriptionSurveySaverTopic.grantPublish(lambdaPublisher.role!!);

    const api = new apiGateway.RestApi(this, "RestApi", {
      restApiName: "RestApi",
    });
    const buySubscription = api.root.addResource("unsubscription_survey");
    buySubscription.addMethod(
      "POST",
      new apiGateway.LambdaIntegration(lambdaPublisher)
    );
  }
}
