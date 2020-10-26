# ACM certificate for *.domain in the default region.
resource "aws_acm_certificate" "wildcard_domain" {
  domain_name       = "*.${var.dns_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ACM certificate for *.domain in us-east-1.
#
# CloudFront can only use certificates in the us-east-1 region, see:
# https://docs.aws.amazon.net/acm/latest/userguide/acm-regions.html
resource "aws_acm_certificate" "wildcard_domain_use1" {
  provider          = aws.use1
  domain_name       = "*.${var.dns_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 validation record(s) for *.domain in the default region.
#
# This record will have the same name, type and value for all certs for the
# same domain in the same account, i.e. certs in different regions.
#
# Since the ACM certificate uses validation method 'DNS', the appropriate
# record is added to the matching DNS zone in Route 53.
resource "aws_route53_record" "domain_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

  allow_overwrite = true
}

# ACM certificate validation for *.domain in the default region.
resource "aws_acm_certificate_validation" "wildcard_domain" {
  certificate_arn         = aws_acm_certificate.wildcard_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_acm_validation : record.fqdn]
}

# ACM certificate validation for *.domain in us-east-1.
resource "aws_acm_certificate_validation" "wildcard_domain_use1" {
  provider                = aws.use1
  certificate_arn         = aws_acm_certificate.wildcard_domain_use1.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_acm_validation : record.fqdn]
}
