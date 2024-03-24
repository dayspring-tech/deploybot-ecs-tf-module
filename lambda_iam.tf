data "aws_cloudfront_distribution" "distribution" {
  id = var.cloudfront_distribution_id

  // only create if a cloudfront distribution is provided
  count = var.cloudfront_distribution_id != null ? 1 : 0
}

resource "aws_iam_policy" "cloudfront_cache_processing" {
  name        = "${var.app_name}-cloudfront-cache-processing-${var.environment}"
  description = "${var.app_name}-cloudfront-cache-processing-${var.environment}"
  path        = "/service-role/"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cloudfront:ListDistributions"
        ],
        "Resource": [
          data.aws_cloudfront_distribution.distribution[0].arn
        ]
      }
    ]
  })

  // only create if a cloudfront distribution is provided
  count = var.cloudfront_distribution_id != null ? 1 : 0
}

resource "aws_iam_role" "deploy_automation" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Sid = ""
      },
    ]
    Version = "2012-10-17"
  })
  managed_policy_arns = concat(
    ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"],
    var.cloudfront_distribution_id != null ? [aws_iam_policy.cloudfront_cache_processing[0].arn] : []
  )
  name = "${var.app_name}_deploy_automation-${var.environment}"
  path = "/service-role/"
}
