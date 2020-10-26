# Route 53 hosted zone.
resource "aws_route53_zone" "main" {
  name = var.dns_domain_name
}

# Main SOA record.
resource "aws_route53_record" "soa_main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_route53_zone.main.name
  type    = "SOA"
  ttl     = "60"

  records = [
    "${aws_route53_zone.main.name_servers[0]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 60",
  ]
}

# Main NS record.
resource "aws_route53_record" "ns_main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_route53_zone.main.name
  type    = "NS"
  ttl     = "172800"

  records = [
    "${aws_route53_zone.main.name_servers[0]}.",
    "${aws_route53_zone.main.name_servers[1]}.",
    "${aws_route53_zone.main.name_servers[2]}.",
    "${aws_route53_zone.main.name_servers[3]}.",
  ]
}

# Point www to the CloudFront distribution.
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
    evaluate_target_health = false
  }
}
