resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Dashboard-${var.bucket_name}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", module.cloudfront.distribution_id, "Region", "Global"],
            [".", "4xxErrorRate", ".", ".", ".", ".", { "stat" : "Average" }],
            [".", "5xxErrorRate", ".", ".", ".", ".", { "stat" : "Average" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "CloudFront Traffic and Errors"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "static-website-waf", "Rule", "ALL"],
            [".", "BlockedRequests", ".", ".", ".", "."]
          ]
          period = 60
          stat   = "Sum"
          region = "us-east-1"
          title  = "WAF Allowed and Blocked"
        }
      }
    ]
  })
}

resource "aws_sns_topic" "alerts" {
  name = "waf-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "malinowski002cloudforge@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "waf_blocks" {
  alarm_name          = "WAF-blocked-requests-threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Metric monitoring the number of WAF blocked requests"

  dimensions = {
    WebACL = module.waf.web_acl_name
    Region = "Global"
    Rule = "ALL"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}