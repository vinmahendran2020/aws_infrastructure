resource "aws_vpc_endpoint" "codeartifact" {
  vpc_id            = module.cluster_vpc.vpc_id
  service_name      = join(".", ["com.amazonaws", var.aws_region, "codeartifact.repositories"])
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = module.cluster_vpc.private_subnets
  security_group_ids = [
    module.eks_sg.this_security_group_id,
    module.eks_cluster.worker_security_group_id
  ]

  tags = var.tags

}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id            = module.cluster_vpc.vpc_id
  service_name      = join(".", ["com.amazonaws", var.aws_region, "ecr.dkr"])
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = module.cluster_vpc.private_subnets
  security_group_ids = [
    module.eks_sg.this_security_group_id,
    module.eks_cluster.worker_security_group_id
  ]

  tags = var.tags
}

resource "aws_vpc_endpoint" "rds" {
  vpc_id            = module.cluster_vpc.vpc_id
  service_name      = join(".", ["com.amazonaws", var.aws_region, "rds"])
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = module.cluster_vpc.private_subnets
  security_group_ids = [
    module.eks_sg.this_security_group_id,
    module.eks_cluster.worker_security_group_id
  ]

  tags = var.tags
}

resource "aws_vpc_endpoint" "mq" {
  count             = var.mq_endpoint_service == "" ? 0 : 1
  vpc_id            = module.cluster_vpc.vpc_id
  service_name      = var.mq_endpoint_service
  vpc_endpoint_type = "Interface"

  # Set private_dns_enable to false when creation as this will fail otherwise
  private_dns_enabled = true
  security_group_ids = [
    module.eks_sg.this_security_group_id,
    module.eks_cluster.worker_security_group_id
  ]

  tags = var.tags
}
