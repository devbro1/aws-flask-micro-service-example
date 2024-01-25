resource "aws_lambda_function" "calculator_service" {
  filename         = data.archive_file.calculator_service.output_path
  function_name    = "calculator_service_lambda_function"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 128
  timeout          = 10
  source_code_hash = data.archive_file.calculator_service.output_base64sha256
}

data "archive_file" "calculator_service" {
  type        = "zip"
  source_dir  = "services/calculator_service"
  output_path = "services/calculator_service.zip"
}


resource "aws_iam_role_policy_attachment" "calculator_service_lambda_execution_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_apigatewayv2_api" "calculator_service" {
  name          = "calculator_service"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "calculator_service_default" {
  api_id    = aws_apigatewayv2_api.calculator_service.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.calculator_service_default.id}"
}

resource "aws_apigatewayv2_integration" "calculator_service_default" {
  api_id           = aws_apigatewayv2_api.calculator_service.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda example"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.calculator_service.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "calculator_service_allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.calculator_service.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_stage" "calculator_service" {
  api_id      = aws_apigatewayv2_api.calculator_service.id
  name        = "$default"
  auto_deploy = true
}

output "calculator_api_gateway_url" {
  value = aws_apigatewayv2_stage.calculator_service.invoke_url
}


resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "calculation_results"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "request_id"

  attribute {
    name = "request_id"
    type = "S"
  }

#   attribute {
#     name = "num1"
#     type = "N"
#   }

#   attribute {
#     name = "num2"
#     type = "N"
#   }

#   attribute {
#     name = "result"
#     type = "N"
#   }
}

