resource "aws_cloudwatch_event_bus" "request_bus" {
  name = "request_bus"
}

resource "aws_cloudwatch_event_rule" "request_rule" {
  name          = "request-rule"
  description   = "calculation request events"
  event_bus_name = aws_cloudwatch_event_bus.request_bus.arn
  event_pattern = <<PATTERN
{
  "source": ["request_event"]
}
PATTERN

}

resource "aws_cloudwatch_event_target" "profile_generator_lambda_target" {
  arn = aws_lambda_function.calculator_service.arn
  rule = aws_cloudwatch_event_rule.request_rule.name
  event_bus_name = aws_cloudwatch_event_bus.request_bus.arn
}

