terraform {
  required_version = "~> 0.12"
  backend "s3" {
    # Either a aws profile or access keys must be specified https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  }
}

provider "aws" {
  version = ">= 3.9.0"
  region  = var.aws_region
  # Either a aws profile or access keys must be specified https://registry.terraform.io/providers/hashicorp/aws/latest/docs
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  alias                  = "eks"
  version                = "~> 1.13.0"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

## Build the VPC, Subnets, NAT Gateways, Route Tables, Routes, IG, VPC Endpoints
module "vpc" {
  source                     = "./modules/vpc"
  environment_name           = var.environment_name
  eks_nodes_sg               = module.eks.worker_security_group_id
  availability_zones         = var.availability_zones
  cidr                       = var.cidr
  public_subnets             = var.public_subnets
  private_subnets            = var.private_subnets
  allowed_ingress_cidr_range = var.allowed_ingress_cidr_range
  allowed_egress_cidr_range  = var.allowed_egress_cidr_range
  public_subnet_tags         = var.public_subnet_tags
  private_subnet_tags        = var.private_subnet_tags
  tags                       = var.tags
}

## Build the EKS Cluster & worker nodes
module "eks" {
  source                      = "./modules/eks"
  environment_name            = var.environment_name
  tags                        = var.tags
  vpc_id                      = module.vpc.vpc_id
  subnets                     = module.vpc.private_subnets
  max_size                    = var.max_size
  min_size                    = var.min_size
  instance_type               = var.instance_type
  root_volume_size            = var.root_volume_size
  asg_desired_capacity        = var.asg_desired_capacity
  cluster_version             = var.cluster_version
  workers_additional_policies = var.workers_additional_policies
}

## Build the ECR Repositories
module "ecr" {
  source              = "./modules/ecr"
  image_names         = var.image_names
  authorized_accounts = var.authorized_accounts
  tags                = var.tags
}

## Build the Cognito user pool
module "cognito" {
  source            = "./modules/cognito"
  environment_name  = var.environment_name
  user_groups       = var.user_groups
  tags              = var.tags
  identity_pool_env = var.identity_pool_env
}

# Build the DNS resources
module "dns" {
  source          = "./modules/dns"
  tags            = var.tags
  dns_name        = var.dns_name
  dns_name_prefix = var.dns_name_prefix
}

# Build the WAF resources
module "waf" {
  source           = "./modules/waf"
  environment_name = var.environment_name
  tags             = var.tags
}

# Build the Elasticache for Redis resources
module "elasticache" {
  source                        = "./modules/elasticache"
  environment_name              = var.environment_name
  tags                          = var.tags
  availability_zones            = var.availability_zones
  subnets                       = module.vpc.private_subnets
  vpc_id                        = module.vpc.vpc_id
  vpc_cidr_block                = module.vpc.vpc_cidr_block
  redis_node_type               = var.redis_node_type
  redis_read_replicas           = var.redis_read_replicas
  redis_snapshot_retention_days = var.redis_snapshot_retention_days
}

# Build the Pipeline resources
module "pipelines" {
  source                            = "./modules/pipelines"
  environment_name                  = var.environment_name
  tags                              = var.tags
  pipelines_run_build               = var.pipelines_run_build
  namespace                         = var.namespace
  stage                             = var.stage
  codebuild_iam_role                = var.codebuild_iam_role
  codepipeline_iam_role             = var.codepipeline_iam_role
  codepipeline_artifact_bucket_name = var.codepipeline_artifact_bucket_name
  dev_account_id                    = var.dev_account_id
  kms_key_name                      = var.kms_key_name
  registry_url                      = var.registry_url
  image_tag                         = var.image_tag
  dns_name                          = var.dns_name
  cognito_client_id                 = module.cognito.cognito_client_id
  cognito_user_pool_id              = module.cognito.cognito_user_pool_id
  cognito_identity_pool_id          = module.cognito.cognito_identity_pool_id

  frontend_repo_name        = var.frontend_repo_name
  frontend_ecr_repo_name    = var.frontend_ecr_repo_name
  frontend_branch_name      = var.frontend_branch_name
  frontend_eks_cluster      = var.frontend_eks_cluster
  frontend_build_spec_name  = var.frontend_build_spec_name
  frontend_deploy_spec_name = var.frontend_deploy_spec_name
  frontend_verify_spec_name = var.frontend_verify_spec_name

  frontend_service_repo_name        = var.frontend_service_repo_name
  frontend_service_ecr_repo_name    = var.frontend_service_ecr_repo_name
  frontend_service_branch_name      = var.frontend_service_branch_name
  frontend_service_eks_cluster      = var.frontend_service_eks_cluster
  frontend_service_build_spec_name  = var.frontend_service_build_spec_name
  frontend_service_deploy_spec_name = var.frontend_service_deploy_spec_name
  frontend_service_verify_spec_name = var.frontend_service_verify_spec_name
}
