locals {
  origin_id = "S3-itcfy-web"
}

# Set up unrestricted CloudFront distribution with an S3 bucket as origin.
resource "aws_cloudfront_distribution" "web" {
  enabled         = true
  comment         = "ITCFY website"
  price_class     = "PriceClass_All"
  is_ipv6_enabled = false
  http_version    = "http2"

  # Load index.html when the user requests the root.
  default_root_object = "index.html"

  aliases = [
    "www.${var.dns_domain_name}",
  ]

  # Origin: S3 bucket.
  origin {
    domain_name = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id   = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web.cloudfront_access_identity_path
    }
  }

  # Default cache behaviour: Use the S3 bucket.
  default_cache_behavior {
    target_origin_id = local.origin_id

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    forwarded_values {
      # Don't forward query strings.
      query_string = false

      # Forward CORS request headers to the origin.
      headers = [
        "Origin",
        "Access-Control-Request-Method",
      ]

      # Don't forward cookies.
      cookies {
        forward = "none"
      }
    }

    # Let CloudFront automatically compress content.
    compress = true

    # Redirect HTTP to HTTPS.
    viewer_protocol_policy = "redirect-to-https"

    # Set the cache TTL values.
    min_ttl     = 10
    default_ttl = 3600
    max_ttl     = 31536000
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.wildcard_domain_use1.arn

    # Only support connections using Server Name Indication.
    ssl_support_method = "sni-only"

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html#secure-connections-supported-ciphers
    minimum_protocol_version = "TLSv1.2_2019"
  }

  # Don't apply any restrictions.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# "An origin access identity is a CloudFront-specific account that allows
# CloudFront to access your restricted Amazon S3 objects."
resource "aws_cloudfront_origin_access_identity" "web" {
  comment = "ITCFY web CloudFront"
}
