resource "aws_lambda_function" "request_service" {
  filename         = data.archive_file.request_service.output_path
  function_name    = "request_service_lambda_function"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 128
  timeout          = 10
  source_code_hash = data.archive_file.request_service.output_base64sha256
}

data "archive_file" "request_service" {
  type        = "zip"
  source_dir  = "services/request_service"
  output_path = "services/request_service.zip"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "lambda_execution_policy"
  description = "Policy for Flask Lambda execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "logs:CreateLogGroup",
      Effect   = "Allow",
      Resource = "*",
      },
      {
        Action   = "logs:CreateLogStream",
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = "logs:PutLogEvents",
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = "*",
        Effect   = "Allow",
        Resource = "*",
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_apigatewayv2_api" "request_serivce" {
  name          = "request_serivce"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "request_service_default" {
  api_id    = aws_apigatewayv2_api.request_serivce.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.request_service_default.id}"
}

resource "aws_apigatewayv2_integration" "request_service_default" {
  api_id           = aws_apigatewayv2_api.request_serivce.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda example"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.request_service.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_service.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_stage" "request_serivce" {
  api_id      = aws_apigatewayv2_api.request_serivce.id
  name        = "$default"
  auto_deploy = true
}

output "service_api_gateway_url" {
  value = aws_apigatewayv2_stage.request_serivce.invoke_url
}