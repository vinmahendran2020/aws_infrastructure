#########################
# AWS PROVIDER VARIABLES
#########################
variable "aws_region" {
  description = "The region where our vpc, subnets and default cloud configuration will live"
  default     = "eu-west-1"
}

variable "aws_access_key" {} # intentionally left blank

variable "aws_secret_key" {} # intentionally left blank, this should NEVER be hardcoded - this can be overriden by export TF_VAR_aws_access_key=xxx in automation

#
# Infrastructure's General Data
#
variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}

###################
# Nodes configuration
###################
variable "max_size" {
  type    = string
  default = "2"
}

variable "min_size" {
  type    = string
  default = "1"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "root_volume_size" {
  type    = string
  default = "20"
}

variable "asg_desired_capacity" {
  type = string
}

###################
# SHARED VARIABLES
###################

variable "availability_zones" {
  description = "A list of availability zones in the region"
  default     = ["us-east-1a", "us-east-1b"]
}

#########################################
# VPC CONFIGURATION VARIABLES
#########################################
variable "cidr" {
  description = "The CIDR block for the prod VPC."
  default     = "172.16.0.0/24"
}

variable "public_subnets" {
  description = "A list of public subnets inside the Production VPC"
  default     = ["172.16.0.0/26", "172.16.0.64/26"]
}

variable "private_subnets" {
  description = "A list of private subnets inside the Production VPC"
  default     = ["172.16.0.128/26", "172.16.0.192/26"]
}

variable "allowed_ingress_cidr_range" {
  description = "The CIDR address range that can connect to the environment"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_egress_cidr_range" {
  description = "The CIDR address range that the environment can connect to"
  default     = ["0.0.0.0/0"]
}

variable "allowed_egress_ports" {
  description = "Allowed outbound ports"
  default     = []
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs in the CloudWatch log group used by the VPC flow logs"
  default     = "14"
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

variable "subnet_tags" {
  description = "The tags to add to all subnets within the VPC"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}

#############################################
# DOMAIN CONFIGURATION
############################################# 

variable "domain_prefix" {
  description = "Domain prefix for AWS hosted zone"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for AWS hosted zone"
  type        = string
  default     = ""
}

#############################################
# VAULT CONFIGURATION
############################################# 

variable "name" {
  description = "Name of the Vault server"
  default     = "vault-instance-test"
}

variable "vault_instance_type" {
  description = "Instance type for the vault server"
  default     = "t2.medium"
}

variable "monitoring" {
  description = "Enable/Disable monitoring of the instance created."
  default     = false
}

variable "vault_port" {
  description = "Port for Vault"
  default     = 8200
}

variable "vault_public_key" {
  description = "The public key of the agent to be able to make a connection between vault instance an agent"
}

variable "vault_min_size" {
  description = "Minimum number of Vault instances"
  default     = "1"
}

variable "vault_max_size" {
  description = "Maximum number of Vault instances"
  default     = "2"
}

####################
# BASTION VARIABLES
####################

variable "bastion_instance_type" {
  description = "Instance type for the vault server"
  default     = "t2.medium"
}

variable "ssh_public_key_names" {
  description = " the name of the key that will make you be able to connect with bastion server"
  default     = ["id_rsa"]
}

variable "bastion_name" {
  description = "Name for the bastion server"
  default     = "blockchain-bastion"
}

variable "bastion_public_key" {
  description = "Public key to connect by default to the bastion."
}

variable "keys_update_frequency" {
  description = "Fequency when the keys are going to be updated"
  default     = "5,20,35,50 * * * *"
}

variable "additional_user_data_script" {
  description = "Additional commands for the user data script"
  default     = "date"
}

variable "cloudinit_userdata" {
  description = "Cloud-init userdata for Bastion AMI"
  default     = null
}

######
# EKS
######

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.12"
}

variable "kubernetes_autoscaling_schedule_enabled" {
  description = "Whether scheduled scaling is enabled"
  type        = bool
  default     = false
}

variable "kubernetes_autoscaling_scale_down_cron" {
  description = "When to scale instances down"
  type        = string
}

variable "kubernetes_autoscaling_scale_up_cron" {
  description = "WHen to scale instances up"
  type        = string
}

variable "workers_additional_policies" {
  description = "Additional policies for worker nodes of the EKS cluster"
  type        = list(string)
}

######
# DB
######

variable "db_identifier" {
  description = "Database identifier"
  type        = string
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Database instance class"
  default     = 50
}

variable "db_user" {
  description = "Database master username"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
  default     = "5432"
}

variable "db_backup_retention" {
  description = "Database backup retention period"
  default     = 1
}

variable "db_password" {} # intentionally left blank, this should NEVER be hardcoded - this can be overriden by export TF_VAR_db_password=xxx in automation

# ECR image repos to be created
variable "image_names" {
  type        = list(string)
  default     = []
  description = "List of Docker local image names, used as repository names for AWS ECR"
}
variable "authorized_accounts" {
  type        = list(string)
  default     = []
  description = "List of Account IDs that will be given access to AWS ECR"
}

# MQ Endpoint variables
variable "mq_endpoint_service" {
  description = "MQ Endpoint Service Name"
  type        = string
  default     = ""
}

# Codepipeline variables
variable "namespace" {
  description = "Namespace for codepipeline"
  type        = string
}
variable "stage" {
  description = "Stage for codepipeline"
  type        = string
}
variable "baf_repo_name" {
  description = "Source repo name for codepipeline"
  type        = string
}
variable "baf_branch_name" {
  description = "Source branch name for codepipeline"
  type        = string
}
variable "git_username" {
  description = "Git username for codepipeline"
  type        = string
}
variable "git_ssh_keyname" {
  description = "SSH Key name for codepipeline"
  type        = string
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
variable "baf_source_version" {
  description = "Source version with for building"
  type        = string
}

variable "buildspec" {
  description = "Buildspec file path"
  type        = string
}

variable "cenm_environment_name" {
  description = "Environment Name of the CENM Cluster"
  type        = string
}
