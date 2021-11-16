# SECURITY GROUPS
module "eks_sg" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-security-group?ref=v3.0.1"

  name        = "eks_sg_${var.environment_name}"
  description = "EKS Security Group for the environment"
  vpc_id      = module.cluster_vpc.vpc_id

  egress_rules       = ["all-all"]
  egress_cidr_blocks = var.allowed_egress_cidr_range

  tags = var.tags
}

module "vault_sg" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-security-group?ref=v3.0.1"

  name        = "vault_private_sg_${var.environment_name}"
  description = "Private Security Group for the VAULT instance"
  vpc_id      = module.cluster_vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion.security_group_id
    },
    {
      from_port                = var.vault_port
      to_port                  = var.vault_port
      protocol                 = "tcp"
      description              = "Vault Port"
      source_security_group_id = module.eks_cluster.worker_security_group_id
    },
    {
      from_port                = var.vault_port
      to_port                  = var.vault_port
      protocol                 = "tcp"
      description              = "Vault Port"
      source_security_group_id = module.bastion.security_group_id
    },
    {
      from_port                = var.vault_port
      to_port                  = var.vault_port
      protocol                 = "tcp"
      description              = "Vault Port for ELB"
      source_security_group_id = module.vault_sg_lb.this_security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 4

  egress_rules       = ["all-all"]
  egress_cidr_blocks = var.allowed_egress_cidr_range

  tags = var.tags
}

module "vault_sg_lb" {
  # following https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-groups.html#elb-vpc-security-groups
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-security-group?ref=v3.0.1"

  name        = "vault_private_sg_lb_${var.environment_name}"
  description = "Private Security Group for the VAULT internal ELB"
  vpc_id      = module.cluster_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.vault_port
      to_port     = var.vault_port
      protocol    = "tcp"
      description = "Vault Port"
      cidr_blocks = var.cidr
    },
  ]

  egress_with_source_security_group_id = [
    {
      from_port                = var.vault_port
      to_port                  = var.vault_port
      protocol                 = "tcp"
      description              = "Vault Port"
      source_security_group_id = module.vault_sg.this_security_group_id
    },
  ]

  tags = var.tags
}

