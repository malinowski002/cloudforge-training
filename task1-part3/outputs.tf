output "cloudfront_url" {
    description = "URL of the website"
    value = "https://${module.cloudfront.distribution_domain_name}"
}