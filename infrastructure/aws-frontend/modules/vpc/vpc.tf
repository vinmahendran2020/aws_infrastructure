data "aws_availability_zones" "available" {}

module "vpc" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-vpc.git"

  name            = var.environment_name
  cidr            = var.cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.public_subnets
  public_subnets  = var.private_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames             = true
  enable_dns_support               = true
  default_vpc_enable_dns_hostnames = true

  tags = var.tags
  vpc_tags = merge({
    "kubernetes.io/cluster/${var.environment_name}-CLUSTER" = "shared"
  }, var.tags)
  public_subnet_tags = merge({
    "kubernetes.io/role/elb"                                = "1",
    "kubernetes.io/cluster/${var.environment_name}-CLUSTER" = "shared"
  }, var.public_subnet_tags)
  private_subnet_tags = merge({
    "kubernetes.io/role/internal-elb"                       = "1",
    "kubernetes.io/cluster/${var.environment_name}-CLUSTER" = "shared"
  }, var.private_subnet_tags)
}

# DEFAULT ENCRYPTION FOR EBS VOLUMES
resource "aws_ebs_encryption_by_default" "cluster" {
  enabled = true
}

#######################
# VPC Endpoint for API Gateway
#######################
data "aws_vpc_endpoint_service" "apigw" {
  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw" {
  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.apigw.service_name
  vpc_endpoint_type = "Interface"

  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [var.eks_nodes_sg]
  private_dns_enabled = true
  tags                = var.tags
}
