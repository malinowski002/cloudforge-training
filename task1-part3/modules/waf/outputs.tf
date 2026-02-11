output "waf_acl_arn" {
    value = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
    value = aws_wafv2_web_acl.this.visibility_config[0].metric_name
}