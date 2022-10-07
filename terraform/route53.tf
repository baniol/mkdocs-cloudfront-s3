data "aws_route53_zone" "main" {
  name         = "shiftbits.net."
  private_zone = false
}

resource "aws_route53_record" "mkdocs" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "mkdocs"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.mkdocs-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.mkdocs-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

## Certificate

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  provider          = aws.virginia

  tags = {
    Name = var.domain_name
  }
}

resource "aws_route53_record" "cert_record" {
  provider = aws.virginia
  for_each = {
    for d in aws_acm_certificate.cert.domain_validation_options :
    d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_record : record.fqdn]
  provider                = aws.virginia
}