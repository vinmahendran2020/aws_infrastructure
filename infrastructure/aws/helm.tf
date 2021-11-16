data "helm_repository" "stable" {
  name = "stable"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "external-dns"
  version    = "3.4.9"

  namespace = "default"

  set_string {
    name  = "provider"
    value = "aws"
  }

  set_string {
    name  = "aws.credentials.accessKey"
    value = var.aws_access_key
  }

  set_string {
    name  = "aws.credentials.secretKey"
    value = var.aws_secret_key
  }

  set_string {
    name  = "aws.region"
    value = var.aws_region
  }

  set_string {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "domainFilters"
    value = "{${var.domain_name}}" # only get the public DNS zone, copied from dns.tf
  }
}
