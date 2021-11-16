#########################
# AWS PROVIDER VARIABLES
#########################
variable "aws_region" {
  description = "The region where our vpc, subnets and default cloud configuration will live"
  default     = "us-east-1"
}

## Infrastructure's General Data
variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
}

## VPC Variables
variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "cidr" {
  description = "The CIDR block for the prod VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets inside the Production VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the Production VPC"
  type        = list(string)
}

variable "allowed_ingress_cidr_range" {
  description = "The CIDR address range that can connect to the environment"
  type        = list(string)
}

variable "allowed_egress_cidr_range" {
  description = "The CIDR address range that the environment can connect to"
  type        = list(string)
}

variable "private_subnet_tags" {
  description = "The tags to add specifically to private subnets within the VPC"
  type        = map(string)
}

variable "public_subnet_tags" {
  description = "The tags to add specifically to public subnets within the VPC"
  type        = map(string)
}

## EKS Variables
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "max_size" {
  description = "max size of EC2 autoscaling group"
  type        = string
}

variable "min_size" {
  description = "max size of EC2 autoscaling group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "root_volume_size" {
  description = "EC2 root volume size"
  type        = string
}

variable "asg_desired_capacity" {
  description = "EC2 autoscaling group desired capacity"
  type        = string
}

variable "workers_additional_policies" {
  description = "Additional policies for worker nodes of the EKS cluster"
  type        = list(string)
}

## DNS Variables
variable "dns_name" {
  description = "The domain name hosted in route53"
  type        = string
}

variable "dns_name_prefix" {
  description = "The prefix to domain name hosted in route53 indicating the record"
  type        = string
}

# ECR variables
variable "image_names" {
  type        = list(string)
  default     = []
  description = "List of Docker local image names, used as repository names for AWS ECR"
}

# ECR variables
variable "authorized_accounts" {
  type        = list(string)
  default     = []
  description = "List of Account IDs that will be given access to AWS ECR"
}

# Cognito Variables
variable "user_groups" {
  description = "Cognito user groups for the user pool"
  type        = map
}

variable "identity_pool_env" {
  description = "Env for Cognito Identity Pool"
  type        = string
  default     = ""
}

# Elasticache Variables
variable "redis_node_type" {
  description = "elasticache node type"
  type        = string
}

variable "redis_read_replicas" {
  description = "number of redis read replicas"
  type        = number
}

variable "redis_snapshot_retention_days" {
  description = "number of days to keep each redis snapshot"
  type        = number
}

# Pipelines Variables
variable "namespace" {
  description = "Namespace for codepipeline"
  type        = string
}
variable "stage" {
  description = "Stage for codepipeline"
  type        = string
}
variable "pipelines_run_build" {
  description = "Determines if the pipelines include a build stage. Build stage is not necessary for higher envs."
  type        = bool
  default     = true
}
variable "codebuild_iam_role" {
  description = "IAM Role name for CodeBuild"
  type        = string
}
variable "codepipeline_iam_role" {
  description = "IAM Role name for CodePipeline"
  type        = string
}
variable "codepipeline_artifact_bucket_name" {
  description = "Name of S3 bucket to store Pipeline artifacts"
  type        = string
}
variable "dev_account_id" {
  description = "DEV AWS Account ID"
  type        = string
}
variable "kms_key_name" {
  description = "Specifies the alias key name of customer managed kms key"
  type        = string
}
variable "registry_url" {
  description = "URL of the ecr registry"
  type        = string
}
variable "image_tag" {
  description = "Specifies the version of build to tag deployment images"
  default     = "latest"
}

variable "frontend_repo_name" {
  description = "Name of the Frontend CodeCommit repo"
  default     = "ion-frontend"
  type        = string
}

variable "frontend_ecr_repo_name" {
  description = "Name of the Frontend ECR repo"
  type        = string
}

variable "frontend_branch_name" {
  description = "Branch of the Frontend CodeCommit repo from where code will be checked out"
  default     = "develop"
  type        = string
}

variable "frontend_eks_cluster" {
  description = "Name of the frontend eks cluster"
  type        = string
}

variable "frontend_build_spec_name" {
  description = "Buildspec path for frontend build"
  type        = string
}

variable "frontend_deploy_spec_name" {
  description = "Buildspec path for frontend deploy"
  type        = string
}

variable "frontend_verify_spec_name" {
  description = "Buildspec path for frontend deployment verification"
  type        = string
}

variable "frontend_service_repo_name" {
  description = "Name of the Frontend Service CodeCommit repo"
  default     = "ion-frontend-service"
  type        = string
}

variable "frontend_service_ecr_repo_name" {
  description = "Name of the Frontend Service ECR repo"
  type        = string
}

variable "frontend_service_branch_name" {
  description = "Branch of the Frontend Service CodeCommit repo from where code will be checked out"
  default     = "develop"
  type        = string
}

variable "frontend_service_eks_cluster" {
  description = "Name of the frontend_service eks cluster"
  type        = string
}

variable "frontend_service_build_spec_name" {
  description = "Buildspec path for frontend_service build"
  type        = string
}

variable "frontend_service_deploy_spec_name" {
  description = "Buildspec path for frontend_service deploy"
  type        = string
}

variable "frontend_service_verify_spec_name" {
  description = "Buildspec path for frontend_service verify deployment & rollback"
  type        = string
}
