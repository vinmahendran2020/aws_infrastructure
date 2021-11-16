## Inherited from root module
variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}

## VPC module specific
variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "cidr" {
  description = "The CIDR block for the prod VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnets inside the Production VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "A list of private subnets inside the Production VPC"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "allowed_ingress_cidr_range" {
  description = "The CIDR address range that can connect to the environment"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_egress_cidr_range" {
  description = "The CIDR address range that the environment can connect to"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "private_subnet_tags" {
  description = "The tags to add specifically to private subnets within the VPC"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "The tags to add specifically to public subnets within the VPC"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}

variable "eks_nodes_sg" {
  description = "Security group ID attached to the EKS workers."
  type        = string
}
