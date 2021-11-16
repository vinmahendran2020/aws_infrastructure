## Inherited from root module
variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC created to hold the EKS cluster"
  type        = string
}

variable "subnets" {
  description = "Private subnets created to hold the worker nodes of the EKS cluster"
  type        = list(string)
}

variable "workers_additional_policies" {
  description = "Additional policies for worker nodes of the EKS cluster"
  type        = list(string)
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}

## EKS module specific
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.16"
}

variable "max_size" {
  description = "max size of EC2 autoscaling group"
  type    = string
  default = "2"
}

variable "min_size" {
  description = "max size of EC2 autoscaling group"
  type    = string
  default = "1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type    = string
  default = "t3.medium"
}

variable "root_volume_size" {
  description = "EC2 root volume size"
  type    = string
  default = "20"
}

variable "asg_desired_capacity" {
  description = "EC2 autoscaling group desired capacity"
  type    = string
  default = "1"
}
