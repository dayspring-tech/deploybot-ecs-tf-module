resource "aws_security_group" "deployment_automation" {
  name        = "${var.app_name}-deployment_automation-${var.environment}"
  vpc_id      = var.vpc_id
  description = "lambda VPC security group"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "archive_file" "lambda_helper_functions_archive" {
  type        = "zip"
  output_path = "./lambda-python/helper-functions.zip"
  source_file = "./lambda-python/helper-functions/function.py"
}


resource "aws_lambda_function" "deployment_automation" {
  function_name = "${var.app_name}-${var.environment}-deployment-automation"
  handler = "function.deployment_automation"
  filename = "./lambda-python/helper-functions.zip"
  memory_size      = 128
  role = aws_iam_role.deploy_automation.arn
  runtime = "python3.11"
  source_code_hash = data.archive_file.lambda_helper_functions_archive.output_base64sha256
  timeout          = 300

  layers = []

  vpc_config {
    subnet_ids = var.lambda_subnet_ids
    security_group_ids = [
      aws_security_group.deployment_automation.id
    ]
  }

  environment {
    variables = {
      TARGET_SERVICE = var.ecs_service_id
      DISTRIBUTION_ID = var.cloudfront_distribution_id
      HOOK_URL = var.slack_hook_url
      SLACK_CHANNEL = var.slack_channel
      ENV_NAME = var.environment
      APP_NAME = var.app_name
    }
  }
}
