# Publish the web S3 bucket name in an SSM param, so that it is easy to consume
# it in the web build+publish step.
resource "aws_ssm_parameter" "web_s3_bucket" {
  type  = "String"
  name  = "/regional/itcfy/web-s3-bucket"
  value = aws_s3_bucket.web.bucket
}
