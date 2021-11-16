variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "subnets" {
  description = "Private subnets created to hold the elasticache nodes"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID containing the elasticache nodes"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC containing the elasticache nodes"
  type        = string
}

variable "redis_node_type" {
  description = "elasticache node type"
  type        = string
  default     = "cache.t3.medium"
}

variable "redis_read_replicas" {
  description = "number of redis read replicas"
  type        = number
  default     = 2
}

variable "redis_snapshot_retention_days" {
  description = "number of days to keep each redis snapshot"
  type        = number
  default     = 5
}
