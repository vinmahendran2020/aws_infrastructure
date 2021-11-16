data "aws_route53_zone" "base_domain" {
  count = var.domain_name != "" ? 1 : 0

  name = "${var.domain_name}." # domains require a trailing dot
}

# base --> external NS
resource "aws_route53_record" "aws_external_ns" {
  # handle the fact that the root domain may not be registered with AWS
  count = var.domain_name != "" ? 1 : 0

  # needs to be explicitly specified here otherwise
  # ERROR -  Because data.aws_route53_zone.base_domain has "count" set, its attributes must be accessed on specific instances.
  zone_id = data.aws_route53_zone.base_domain[count.index].zone_id
  name    = join(".", [var.domain_prefix, var.domain_name])
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.external.name_servers.0}",
    "${aws_route53_zone.external.name_servers.1}",
    "${aws_route53_zone.external.name_servers.2}",
    "${aws_route53_zone.external.name_servers.3}",
  ]
}

# EXTERNAL
resource "aws_route53_zone" "external" {
  name = join(".", [var.domain_prefix, var.domain_name])
}

# external NS --> internal NS
resource "aws_route53_record" "aws_internal_ns" {
  zone_id = aws_route53_zone.external.zone_id
  name    = join(".", ["internal", var.domain_prefix, var.domain_name])
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.internal.name_servers.0}",
    "${aws_route53_zone.internal.name_servers.1}",
    "${aws_route53_zone.internal.name_servers.2}",
    "${aws_route53_zone.internal.name_servers.3}",
  ]
}

# bastion associations
# create DNS record for each Bastion machine
resource "aws_route53_record" "bastion_machine_record" {
  count   = length(module.bastion.bastion_public_ips)
  zone_id = aws_route53_zone.external.zone_id
  name    = "${count.index + 1}.bastion."
  type    = "A"
  ttl     = "60"
  records = [module.bastion.bastion_public_ips[count.index]]
}

# INTERNAL
resource "aws_route53_zone" "internal" {
  name = join(".", ["internal", var.domain_prefix, var.domain_name])

  # set as private zone
  vpc {
    vpc_id = module.cluster_vpc.vpc_id
  }
}

# create DNS record for Vault machines using vault internal lb
resource "aws_route53_record" "vault_record" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "vault."
  type    = "CNAME"
  ttl     = "300"
  records = [module.vault_internal_lb.this_elb_dns_name]
}
