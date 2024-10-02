provider "aws" {
  region = "eu-north-1"
  access_key = "AKIAZI2LCETGIPIUFFMR"
  secret_key = "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"
}
resource "aws_s3_bucket" "static_website" {
  bucket = "my-staticc-hosting"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
resource "aws_s3_bucket_object" "website_assets" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  source = "https://my-staticc-hosting.s3.amazonaws.com/index.html"  # Update this path to where your index.html is located
  acl    = "public-read"
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access Identity for S3 Bucket"
}
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.static_website.id}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.static_website.id}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}