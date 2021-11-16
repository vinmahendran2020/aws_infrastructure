#################
# VPC
#################
data "aws_availability_zones" "available" {
  state = "available"
}

module "cluster_vpc" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-vpc?ref=v2.7.4"

  environment_name = var.environment_name
  cidr             = var.cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = data.aws_availability_zones.available.names

  enable_dns_hostnames             = true
  enable_dns_support               = true
  default_vpc_enable_dns_hostnames = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  log_retention_in_days = var.log_retention_in_days

  tags                = var.tags
  vpc_tags            = merge({ "kubernetes.io/cluster/${var.environment_name}-CLUSTER" = "shared" }, var.tags)
  public_subnet_tags  = merge({ "kubernetes.io/role/elb" = "1" }, var.public_subnet_tags)
  private_subnet_tags = merge({ "kubernetes.io/role/internal-elb" = "1" }, var.private_subnet_tags)
  subnet_tags         = merge({ "kubernetes.io/cluster/${var.environment_name}-CLUSTER" = "shared" }, var.subnet_tags)
}

# DEFAULT  ENCRYPTION FOR EBS VOLUMES
resource "aws_ebs_encryption_by_default" "cluster" {
  enabled = true
}
