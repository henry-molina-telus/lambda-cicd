/*
 * An API gateway to expose our function
 * to the Internet
 */
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "api-gateway"
  protocol_type = "HTTP"
  tags          = {}
}

/*
 * Default stage for our API gateway
 * with basic access logs
 */
resource "aws_apigatewayv2_stage" "api_gateway_default_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
  tags        = {}

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      status                  = "$context.status"
      responseLatency         = "$context.responseLatency"
      path                    = "$context.path"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

/*
 * Integrate our function with our API gateway
 * so that they can communicate
 */
resource "aws_apigatewayv2_integration" "api_gateway_integration" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_uri    = "${aws_lambda_function.api_lambda.arn}:${aws_lambda_alias.api_lambda_alias.name}"
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  request_parameters = {}
  request_templates  = {}
}

/*
 * Tell our API gateway to forward all incoming
 * requests (every path + HTTP verb) to our function
 */
resource "aws_apigatewayv2_route" "api_gateway_any_route" {
  api_id               = aws_apigatewayv2_api.api_gateway.id
  route_key            = "ANY /{proxy+}"
  target               = "integrations/${aws_apigatewayv2_integration.api_gateway_integration.id}"
  authorization_scopes = []
  request_models       = {}
}

/*
 * Tell Terraform to output the URL
 * of our default API gateway stage after each `terraform apply`
 */
output "api_gateway_invoke_url" {
  description = "API gateway default stage invokation URL"
  value       = aws_apigatewayv2_stage.api_gateway_default_stage.invoke_url
}
