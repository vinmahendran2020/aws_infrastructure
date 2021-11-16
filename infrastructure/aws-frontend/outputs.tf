output "ssl_cert_arn" {
  value = module.dns.ssl_cert_arn
}

output "waf_arn" {
  value = module.waf.waf_arn
}

output "cluster_id" {
  value = module.eks.cluster_id
}
