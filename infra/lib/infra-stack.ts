import * as cdk from "aws-cdk-lib";
import * as apiGateway from "aws-cdk-lib/aws-apigateway";
import { Construct } from "constructs";
import { Stage } from "./types";
import { UnsubscriptionSurveySaver } from "./unsubscription_survey_saver/construct";

export class InfraStack extends cdk.Stack {
  constructor(
    scope: Construct,
    id: string,
    stage: Stage,
    props?: cdk.StackProps
  ) {
    super(scope, id, props);

    const unsubscriptionSurveySaver = new UnsubscriptionSurveySaver(
      this,
      "UnsubscriptionSurveySaver",
      stage
    );

    const api = new apiGateway.RestApi(this, "RestApi", {
      restApiName: "RestApi",
    });
    const unsubscriptionSurveyResource = api.root.addResource(
      "unsubscription_survey"
    );
    unsubscriptionSurveyResource.addMethod(
      "POST",
      new apiGateway.LambdaIntegration(unsubscriptionSurveySaver.lambda)
    );

    new cdk.CfnOutput(this, "API_GATEWAY", {
      value: api.url,
    }).overrideLogicalId("API_GATEWAY");
  }
}
