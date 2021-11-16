variable "tags" {
  description = "Tags for every resource made by the module"
  type    = map(string)
  default = {}
}

variable "dns_name" {
  description = "The domain name hosted in route53"
  type    = string
  default = ""
}

variable "dns_name_prefix" {
  description = "The prefix to domain name hosted in route53 indicating the record"
  type    = string
  default = ""
}
