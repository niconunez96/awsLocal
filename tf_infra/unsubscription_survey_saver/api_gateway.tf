resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:us-east-1:000000000000:${aws_api_gateway_rest_api.tf_rest_api.id}/*/**"
}

resource "aws_api_gateway_rest_api" "tf_rest_api" {
  name = "tf_rest_api"
}

resource "aws_api_gateway_resource" "unsubscription_survey" {
  parent_id   = aws_api_gateway_rest_api.tf_rest_api.root_resource_id
  path_part   = "unsubscription_survey"
  rest_api_id = aws_api_gateway_rest_api.tf_rest_api.id
}

resource "aws_api_gateway_method" "save_unsubscription_survey" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.unsubscription_survey.id
  rest_api_id   = aws_api_gateway_rest_api.tf_rest_api.id
}

resource "aws_api_gateway_integration" "save_unsubscription_survey_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tf_rest_api.id
  resource_id             = aws_api_gateway_resource.unsubscription_survey.id
  http_method             = aws_api_gateway_method.save_unsubscription_survey.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_function.invoke_arn
}

resource "aws_api_gateway_deployment" "tf_rest_api" {
  rest_api_id = aws_api_gateway_rest_api.tf_rest_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.unsubscription_survey.id,
      aws_api_gateway_method.save_unsubscription_survey.id,
      aws_api_gateway_integration.save_unsubscription_survey_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "tf_rest_api" {
  deployment_id = aws_api_gateway_deployment.tf_rest_api.id
  rest_api_id   = aws_api_gateway_rest_api.tf_rest_api.id
  stage_name    = var.env
}
