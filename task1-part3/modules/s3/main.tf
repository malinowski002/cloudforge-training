resource "aws_s3_bucket" "this" {
    bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "this" {
    bucket = aws_s3_bucket.this.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    index_document {
        suffix = "index.html"
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_ownership_controls" "logs"{
    bucket = aws_s3_bucket.logs.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "logs_acl" {
    depends_on = [aws_s3_bucket_ownership_controls.logs]

    bucket = aws_s3_bucket.logs.id
    acl = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "logs_versioning" {
    bucket = aws_s3_bucket.logs.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
    bucket = aws_s3_bucket.logs.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
    bucket = aws_s3_bucket.logs.id

    rule {
        id = "expire-logs-30-days"
        status = "Enabled"

        filter {}

        expiration {
            days = 30
        }
    }
}