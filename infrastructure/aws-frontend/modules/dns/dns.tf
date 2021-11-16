data "aws_route53_zone" "selected_zone" {
  name         = var.dns_name
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.dns_name_prefix}.${var.dns_name}"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_route53_record" "dns_record" {
#   zone_id = data.aws_route53_zone.selected_zone.zone_id
#   name    = "${var.dns_name_prefix}.${var.dns_name}"
#   type    = "A"

#   alias {
#     name                   = var.lb_dns_name
#     zone_id                = var.lb_zone_id
#     evaluate_target_health = true
#   }
# }

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]

  timeouts {
    create = "30m"
  }
}
