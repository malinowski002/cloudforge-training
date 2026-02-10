module "waf" {
    source = "./modules/waf"
    providers = {
        aws = aws.us_east_1
    }
}

module "s3" {
    source = "./modules/s3"
    bucket_name = var.bucket_name
}

module "cloudfront" {
    source = "./modules/cloudfront"
    s3_bucket_id = module.s3.bucket_id
    s3_bucket_origin_domain_name = module.s3.bucket_regional_domain_name
    web_acl_id = module.waf.waf_acl_arn
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
    bucket = module.s3.bucket_id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "AllowCloudFrontServicePrincipalReadOnly"
                Effect = "Allow"
                Principal = {Service = "cloudfront.amazonaws.com"}
                Action = "s3:GetObject"
                Resource = "${module.s3.bucket_arn}/*"
                Condition = {
                    StringEquals = {
                        "AWS:SourceArn" = module.cloudfront.distribution_arn
                    }
                }
            }
        ]
    })
}

resource "aws_s3_object" "index" {
    bucket = module.s3.bucket_id
    key = "index.html"
    source = "index.html"
    content_type = "text/html"
}