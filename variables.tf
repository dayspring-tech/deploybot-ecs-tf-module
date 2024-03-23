variable "app_name" {
  description = "App name"
}

variable "environment" {
  description = "This environment name will be included in the name of most resources."
}

variable "cloudfront_distribution_id" {
  description = "Distribution ID of the CloudFront distribution to create an invalidation for"
}

variable "ecs_service_id" {
  description = "ECS service ID to watch for deployments from"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "lambda_subnet_ids" {
  description = "Subnet IDs for the Lambda function"
  type = list(string)
}

variable "slack_hook_url" {
  description = "Slack webhook URL"
}

variable "slack_channel" {
  description = "Slack channel to post in"
}
