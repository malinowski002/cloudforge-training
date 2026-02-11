resource "aws_wafv2_web_acl" "this" {
    name = var.waf_name
    scope = "CLOUDFRONT"

    default_action {
        allow {}
    }

    rule {
        name = "AWSManagedRulesAmazonIpReputationList"
        priority = 1
        override_action {
            none {}
        }
        statement {
            managed_rule_group_statement {
                name = "AWSManagedRulesAmazonIpReputationList"
                vendor_name = "AWS"
            }
        }
        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name = "WafReputationMetric"
            sampled_requests_enabled = true
        }
    }

    rule {
        name = "IPRateLimit"
        priority = 2
        action {
            block {}
        }

        statement {
            rate_based_statement {
                limit = 100
                aggregate_key_type = "IP"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name = "IPRateLimitMetric"
            sampled_requests_enabled = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "static-website-waf"
        sampled_requests_enabled = true
    }
}