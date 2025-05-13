# Define CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "S3-Origin-Access-Control"
  description                       = "OAC for S3 Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always" # Always signs requests
  signing_protocol                  = "sigv4"  # Uses AWS SigV4 authentication
}

# Define CloudFront Distribution
resource "aws_cloudfront_distribution" "cf_dist" {
  # Origin Configuration
  origin {
    domain_name              = var.frontend_bucket_regional_domain_name # Ensure this is the S3 bucket's regional domain name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id # Uses OAC
    origin_id                = var.frontend_bucket_name # A unique identifier for the origin
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for S3 Bucket"
  default_root_object = "index.html"

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.frontend_bucket_name
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  # Geo-Restriction (if needed)
  restrictions {
    geo_restriction {
      restriction_type = "none" # Updated to "none" since the whitelist is empty
    }
  }


  # SSL/TLS Security Configuration
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}