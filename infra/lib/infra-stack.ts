import * as cdk from "aws-cdk-lib";
import * as apiGateway from "aws-cdk-lib/aws-apigateway";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as sns from "aws-cdk-lib/aws-sns";
import * as sqs from "aws-cdk-lib/aws-sqs";
import { Construct } from "constructs";

export class InfraStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const domainQueue = new sqs.Queue(this, "DomainQueue", {
      queueName: "DomainQueue",
      visibilityTimeout: cdk.Duration.seconds(300),
    });
    const subscriptionBoughtSNSTopic = new sns.Topic(
      this,
      "SubscriptionBought",
      {
        topicName: "SubscriptionBought",
      }
    );
    new sns.Subscription(this, "SubscriptionBoughtSub", {
      topic: subscriptionBoughtSNSTopic,
      protocol: sns.SubscriptionProtocol.SQS,
      endpoint: domainQueue.queueArn,
    });

    const lambdaPublisher = new lambda.Function(this, "LambdaPublisher", {
      functionName: "LambdaPublisher",
      description: "Lambda that publishes to a SNS",
      runtime: lambda.Runtime.PYTHON_3_9,
      code: lambda.Code.fromAsset("../lambdas/src"),
      handler: "subscription_bought_publisher.handler",
      environment: {
        SUBSCRIPTION_BOUGHT_TOPIC_ARN: subscriptionBoughtSNSTopic.topicArn,
      },
    });
    subscriptionBoughtSNSTopic.grantPublish(lambdaPublisher.role!!);

    const api = new apiGateway.RestApi(this, "RestApi", {
      restApiName: "RestApi",
    });
    const buySubscription = api.root.addResource("buy_subscription");
    buySubscription.addMethod(
      "POST",
      new apiGateway.LambdaIntegration(lambdaPublisher)
    );
  }
}
