import * as cdk from "aws-cdk-lib";
import * as apiGateway from "aws-cdk-lib/aws-apigateway";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as sns from "aws-cdk-lib/aws-sns";
import * as sqs from "aws-cdk-lib/aws-sqs";
import { Construct } from "constructs";

export class InfraStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here

    const queue = new sqs.Queue(this, "InfraQueue", {
      queueName: "InfraQueue",
      visibilityTimeout: cdk.Duration.seconds(300),
    });
    const topic = new sns.Topic(this, "InfraTopic", {
      topicName: "InfraTopic",
    });
    new sns.Subscription(this, "InfraSub", {
      topic,
      protocol: sns.SubscriptionProtocol.SQS,
      endpoint: queue.queueArn,
    });
    const powerToolsLayer = lambda.LayerVersion.fromLayerVersionArn(
      this,
      "lambda-powertools",
      `arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:12`
    );
    const lambdaPublisher = new lambda.Function(this, "LambdaPublisher", {
      functionName: "LambdaPublisher",
      description: "Lambda that publishes to a SNS",
      runtime: lambda.Runtime.PYTHON_3_9,
      code: lambda.Code.fromAsset("../lambdas/src"),
      handler: "subscription_bought_publisher.handler",
      layers: [powerToolsLayer],
      environment: {
        TOPIC_ARN: topic.topicArn,
      },
    });
    topic.grantPublish(lambdaPublisher.role!!);
    const api = new apiGateway.RestApi(this, "RestApi", {
      restApiName: "RestApi",
    });
    api.root.addMethod(
      "GET",
      new apiGateway.LambdaIntegration(lambdaPublisher)
    );
  }
}
