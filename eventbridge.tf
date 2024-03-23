resource "aws_lambda_permission" "eventbridge_invoke_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deployment_automation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_deployment_event_pattern.arn
}

resource "aws_cloudwatch_event_rule" "ecs_deployment_event_pattern" {
  name                = "${var.app_name}-deploybot-${var.environment}"
  description         = "ECS Deployment Event Rule"
  event_pattern       = jsonencode({
    "source": ["aws.ecs"],
    "detail-type": ["ECS Deployment State Change"]
  })
}

resource "aws_cloudwatch_event_target" "target_lambda" {
  rule      = aws_cloudwatch_event_rule.ecs_deployment_event_pattern.name
  target_id = "target-lambda"
  arn       = aws_lambda_function.deployment_automation.arn
}
