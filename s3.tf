# Bucket for Terraform remote backend.
resource "aws_s3_bucket" "terraform_remote_backend" {
  bucket = "${local.s3_bucket_prefix}-tfstate-testcases"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# Bucket for PR testing.
resource "aws_s3_bucket" "test123" {
  bucket = "${local.s3_bucket_prefix}-test123"
  acl    = "private"
}

# Create S3 bucket for holding files. Note that the bucket is assigned the
# 'private' ACL by default, while the contents are intended to be public. The
# idea is that the bucket itself will indeed be private, but allows access via
# the CloudFront Origin Access Identity, which in practice makes the contents
# public due to the CloudFront distribution not applying any restrictions
# itself.
resource "aws_s3_bucket" "web" {
  bucket = "${local.s3_bucket_prefix}-itcfy-web"

  # Cross-Origin Resource Sharing configuration.
  cors_rule {
    # Allow any header.
    allowed_headers = [
      "*",
    ]

    # Allow GET only.
    allowed_methods = [
      "GET",
    ]

    # Allow any origin.
    allowed_origins = [
      "*",
    ]

    # Expose the ETag header in the response.
    expose_headers = [
      "ETag",
    ]

    # Set the CORS TTL to 1 hour.
    max_age_seconds = 3600
  }
}

# Policy document granting object read access to the specified CloudFront
# Origin Access Identity.
data "aws_iam_policy_document" "web_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.web.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.web.iam_arn,
      ]
    }
  }
}

# Apply the policy to the bucket.
resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web.id
  policy = data.aws_iam_policy_document.web_bucket_policy.json
}
